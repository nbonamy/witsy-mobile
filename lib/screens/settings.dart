import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:witsy/components/picker_page.dart';
import 'package:witsy/http/llm.dart';
import 'package:witsy/models/model.dart';
import 'package:witsy/models/preferences.dart';
import 'package:witsy/models/engine.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final defaultModels = {
    'openai': 'gpt-4o',
    'anthropic': 'claude-3-5-sonnet-latest',
    'mistralai': 'mistral-large-latest',
    'google': 'models/gemini-1.5-pro-latest',
    'xai': 'grok-beta',
    'groq': 'llama-3.2-90b-text-preview',
    'cerebras': 'llama3.1-70b',
  };

  Engine _selectedEngine = Engine(id: 'openai', name: 'OpenAI');
  Model? _selectedModel = Model(id: 'gpt-4o', name: 'GPT-4o');

  List<Engine> _engines = [];
  List<Model> _models = [];

  @override
  void initState() {
    super.initState();
    final prefs = Provider.of<Preferences>(context, listen: false);
    _selectedEngine = prefs.engine;
    _selectedModel = prefs.model;
    _loadEngines();
    _loadModels();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('LLM'),
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pickProvider,
                  child: CupertinoFormRow(
                    prefix: const Text('Provider'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          onPressed: _pickProvider,
                          padding: EdgeInsets.zero,
                          child: Text(_selectedEngine.name),
                        ),
                        const SizedBox(width: 8),
                        const CupertinoListTileChevron(),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pickModel,
                  child: CupertinoFormRow(
                    prefix: const Text('Model'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          onPressed: _pickModel,
                          padding: EdgeInsets.zero,
                          child: Text(_selectedModel?.name ?? ''),
                        ),
                        const SizedBox(width: 8),
                        const CupertinoListTileChevron(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _loadEngines() async {
    _engines = await LlmClient().engines();
    // Load providers from the server.
  }

  _loadModels() async {
    _models = await LlmClient().models(_selectedEngine);
    setState(() {
      if (_models.isEmpty) {
        _selectedModel = null;
      } else {
        if (!_models.any((model) => model.id == _selectedModel?.id)) {
          var defaultModel = defaultModels[_selectedEngine.id];
          _selectedModel = _models.firstWhere(
            (element) => element.id == defaultModel,
            orElse: () => _models.first,
          );
          final prefs = Provider.of<Preferences>(context, listen: false);
          prefs.setModel(_selectedModel!);
        }
      }
    });
  }

  _pickProvider() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) {
          return PickerPage(
            title: 'Select Provider',
            sectionTitle: 'Providers',
            options: _engines.map((provider) {
              return Option(id: provider.id, label: provider.name);
            }).toList(),
            selected: Option(
              id: _selectedEngine.id,
              label: _selectedEngine.name,
            ),
            onSelected: _onProviderSelected,
          );
        },
      ),
    );
  }

  _onProviderSelected(engineId) {
    if (_selectedEngine.id == engineId) {
      return;
    }
    setState(() {
      _selectedEngine = _engines.firstWhere(
        (element) => element.id == engineId,
      );
      final prefs = Provider.of<Preferences>(context, listen: false);
      prefs.setEngine(_selectedEngine);
      _selectedModel = null;
      _loadModels();
    });
  }

  _pickModel() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) {
          return PickerPage(
            title: 'Select Model',
            sectionTitle: 'Models',
            options: _models.map((model) {
              return Option(id: model.id, label: model.name);
            }).toList(),
            selected: _selectedModel != null
                ? Option(id: _selectedModel!.id, label: _selectedModel!.name)
                : null,
            onSelected: _onModelSelected,
          );
        },
      ),
    );
  }

  _onModelSelected(String modelId) {
    setState(() {
      _selectedModel = _models.firstWhere(
        (element) => element.id == modelId,
      );
      final prefs = Provider.of<Preferences>(context, listen: false);
      prefs.setModel(_selectedModel!);
    });
  }
}
