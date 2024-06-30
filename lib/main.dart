import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Immobilière',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: LoginPage(toggleTheme: _toggleTheme),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Function toggleTheme;

  const LoginPage({super.key, required this.toggleTheme});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    if (email == 'saadackerman9@gmail.com' && password == '60641390') {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PropertiesPage(toggleTheme: widget.toggleTheme)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de connexion'),
          content: const Text('Email ou mot de passe incorrect'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Adresse email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: const Text('Se connecter'),
            ),
            TextButton(
              onPressed: () {
                // Logic for "Forgot Password"
              },
              child: const Text('Mot de passe oublié ?'),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertiesPage extends StatefulWidget {
  final Function toggleTheme;

  const PropertiesPage({super.key, required this.toggleTheme});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  List<Property> properties = [];

  void _addProperty(String type, String description) {
    setState(() {
      properties.add(Property(id: DateTime.now().toString(), type: type, description: description));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propriétés'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Propriétés'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Locataires'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TenantsPage(properties: properties),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alertes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlertsPage(properties: properties),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: properties.isEmpty
          ? const Center(
        child: Text('Aucune propriété ajoutée.'),
      )
          : ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return Card(
            child: ListTile(
              leading: Icon(
                property.type == 'Appartement'
                    ? Icons.apartment
                    : Icons.king_bed,
              ),
              title: Text(property.type),
              subtitle: Text(property.description),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetailsPage(property: property),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPropertyPage(onAdd: _addProperty),
            ),
          );
        },
        tooltip: 'Ajouter Propriété',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPropertyPage extends StatefulWidget {
  final Function(String, String) onAdd;

  const AddPropertyPage({super.key, required this.onAdd});

  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Appartement';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_selectedType, _descriptionController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter Propriété'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Appartement'),
                secondary: const Icon(Icons.apartment),
                value: 'Appartement',
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Chambre'),
                secondary: const Icon(Icons.king_bed),
                value: 'Chambre',
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyDetailsPage extends StatefulWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  _PropertyDetailsPageState createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final _tenantNameController = TextEditingController();
  final _tenantSurnameController = TextEditingController();
  final _tenantNNIController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _electricityPaymentController = TextEditingController();
  final _waterPaymentController = TextEditingController();
  DateTime? _contractStartDate;
  DateTime? _contractEndDate;

  void _submitTenant() {
    setState(() {
      widget.property.tenant = Tenant(
        name: _tenantNameController.text,
        surname: _tenantSurnameController.text,
        nni: _tenantNNIController.text,
        rent: double.parse(_paymentAmountController.text),
        electricityPayment: double.parse(_electricityPaymentController.text),
        waterPayment: double.parse(_waterPaymentController.text),
        contractStartDate: _contractStartDate!,
        contractEndDate: _contractEndDate!,
      );
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.property.type == 'Appartement') {
      _paymentAmountController.text = '100000';
      _electricityPaymentController.text = '2000';
      _waterPaymentController.text = '2000';
    } else {
      _paymentAmountController.text = '50000';
      _electricityPaymentController.text = '1000';
      _waterPaymentController.text = '1000';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = widget.property.tenant;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.type),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: tenant == null
            ? SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _tenantNameController,
                decoration: const InputDecoration(labelText: 'Nom du locataire'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tenantSurnameController,
                decoration: const InputDecoration(labelText: 'Prénom du locataire'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tenantNNIController,
                decoration: const InputDecoration(labelText: 'Numéro NNI'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _paymentAmountController,
                decoration: const InputDecoration(labelText: 'Paiement de l\'appartement/chambre'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _electricityPaymentController,
                decoration: const InputDecoration(labelText: 'Paiement de l\'électricité'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _waterPaymentController,
                decoration: const InputDecoration(labelText: 'Paiement de l\'eau'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _contractStartDate = picked;
                    });
                  }
                },
                child: Text(_contractStartDate == null
                    ? 'Sélectionner la date de début de contrat'
                    : 'Début de contrat : ${DateFormat('dd/MM/yyyy').format(_contractStartDate!)}'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _contractEndDate = picked;
                    });
                  }
                },
                child: Text(_contractEndDate == null
                    ? 'Sélectionner la date d\'expiration de contrat'
                    : 'Expiration de contrat : ${DateFormat('dd/MM/yyyy').format(_contractEndDate!)}'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitTenant,
                child: const Text('Enregistrer Locataire et Paiements'),
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Locataire: ${tenant.name} ${tenant.surname}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text('NNI: ${tenant.nni}'),
            const SizedBox(height: 8),
            Text('Paiement: ${tenant.rent} FCFA'),
            const SizedBox(height: 8),
            Text('Électricité: ${tenant.electricityPayment} FCFA'),
            const SizedBox(height: 8),
            Text('Eau: ${tenant.waterPayment} FCFA'),
            const SizedBox(height: 8),
            Text('Début de contrat: ${DateFormat('dd/MM/yyyy').format(tenant.contractStartDate)}'),
            const SizedBox(height: 8),
            Text('Expiration de contrat: ${DateFormat('dd/MM/yyyy').format(tenant.contractEndDate)}'),
          ],
        ),
      ),
    );
  }
}

class TenantsPage extends StatelessWidget {
  final List<Property> properties;

  const TenantsPage({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    List<Tenant> tenants = properties
        .where((property) => property.tenant != null)
        .map((property) => property.tenant!)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locataires'),
      ),
      body: tenants.isEmpty
          ? const Center(
        child: Text('Aucun locataire inscrit.'),
      )
          : ListView.builder(
        itemCount: tenants.length,
        itemBuilder: (context, index) {
          final tenant = tenants[index];
          return Card(
            child: ListTile(
              title: Text('${tenant.name} ${tenant.surname}'),
              subtitle: Text('NNI: ${tenant.nni}\n'
                  'Paiement: ${tenant.rent} FCFA\n'
                  'Électricité: ${tenant.electricityPayment} FCFA\n'
                  'Eau: ${tenant.waterPayment} FCFA\n'
                  'Début de contrat: ${DateFormat('dd/MM/yyyy').format(tenant.contractStartDate)}\n'
                  'Expiration de contrat: ${DateFormat('dd/MM/yyyy').format(tenant.contractEndDate)}'),
            ),
          );
        },
      ),
    );
  }
}

class AlertsPage extends StatelessWidget {
  final List<Property> properties;

  const AlertsPage({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<String> alerts = [];

    for (var property in properties) {
      if (property.tenant != null) {
        if (property.tenant!.contractEndDate.isBefore(now)) {
          alerts.add(
              'Le contrat de ${property.tenant!.name} ${property.tenant!.surname} pour la propriété ${property.description} a expiré.');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
      ),
      body: alerts.isEmpty
          ? const Center(
        child: Text('Aucune alerte.'),
      )
          : ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(alerts[index]),
            ),
          );
        },
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Function toggleTheme;

  const SettingsPage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => toggleTheme(),
          child: const Text('Changer le thème'),
        ),
      ),
    );
  }
}

class Property {
  final String id;
  final String type;
  final String description;
  Tenant? tenant;

  Property({required this.id, required this.type, required this.description, this.tenant});
}

class Tenant {
  final String name;
  final String surname;
  final String nni;
  final double rent;
  final double electricityPayment;
  final double waterPayment;
  final DateTime contractStartDate;
  final DateTime contractEndDate;

  Tenant({
    required this.name,
    required this.surname,
    required this.nni,
    required this.rent,
    required this.electricityPayment,
    required this.waterPayment,
    required this.contractStartDate,
    required this.contractEndDate,
  });
}
