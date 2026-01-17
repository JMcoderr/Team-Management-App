import 'package:flutter/material.dart';
import 'package:team_management_app_dev/data/services/teams_service.dart';

// CreateTeamPage allows users to create new teams
class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  // form key validates inputs before submission
  final _formKey = GlobalKey<FormState>();

  // controllers store text input values
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false; // spinner during loading

  // validates form and submits team data to API
  Future<void> _createTeam() async {
    // stops if validation fails
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // sends team data to API for creation
      await TeamsService().createTeam(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      
      // confirms successful team creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // returns true to notify parent page to refresh team list
      Navigator.pop(context, true);
    } catch (e) {
      // displays error message if creation fails
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create team: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTeam,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Team'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
