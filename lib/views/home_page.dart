import 'package:buscadecep/models/result_cep.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flushbar/flushbar.dart';

import '../services/via_cep_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _searchCepController = TextEditingController();

  TextEditingController _cepController = TextEditingController();
  TextEditingController _ruaController = TextEditingController();
  TextEditingController _bairroController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();
  TextEditingController _estadoController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _formResult = GlobalKey<FormState>();

  bool _loading = false;
  bool _enableField = true;
  String _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta Cep'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              changeBrightness();
              //changeColor();
            },
            icon: Icon(Icons.lightbulb_outline),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(" CEP:  ${_cepController.text}\n"
                  " Rua:  ${_ruaController.text}\n "
                  "Bairro:  ${_bairroController.text}\n"
                  " Cidade:  ${_cidadeController.text}\n"
                  " Estado:  ${_estadoController.text}");
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildResultCepText(),
        Form(
          key: _formKey,
          child: _buildSearchCepTextField(),
        ),
        _buildSearchCepButton(),
        _buscaForm(),
      ],
    );
  }

  ResultCep _resultCep;

  Widget _buildResultCepText() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Text(_resultCep != null ? _resultCep.toJson() : 'Digite um Cep'),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Cep'),
      controller: _searchCepController,
      enabled: _enableField,
      autovalidate: false,
      validator: (String str) {
        str = str.replaceAll(r'-', r'');

        if (str == '') {
          limparResultado();
          return '';
        } else if (str.length != 8) {
          limparResultado();
          return 'Digite um CEP válido!';
        } else if (num.tryParse(str) == null) {
          limparResultado();
          return 'CEP deve contar apenas números e um traço!';
        } else
          return null;
      },
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _searchCep();
          }
        },
        child: _loading ? _circularLoading() : Text('Consultar'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Widget _circularLoading() {
    return Container(
      width: 15.0,
      height: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  void _searching({bool enable}) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  void limparResultado() {
    setState(() {
      _ruaController.text = "";
      _cepController.text = "";
      _bairroController.text = "";
      _cidadeController.text = "";
      _estadoController.text = "";
    });
  }

  Future _searchCep() async {
    _searching(enable: true);
    final cep = _searchCepController.text;
    final result = await ViaCepService.fetchCep(cep: cep);

    print(result);

    if (result != null) {
      setState(() {
        _cepController.text = result.cep;
        _ruaController.text = result.logradouro;
        _bairroController.text = result.bairro;
        _cidadeController.text = result.localidade;
        _estadoController.text = result.uf;
      });
    } else {
      Flushbar(
        message: "OCORREU UM ERRO,!",
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.error, size: 30, color: Theme.of(context).errorColor),
      )..show(context);
      limparResultado();
    }

    _searching(enable: false);
  }

  Form _buscaForm() {
    return Form(
      key: _formResult,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildTextFormField(label: "Cep", controller: _cepController),
          buildTextFormField(label: "Rua", controller: _ruaController),
          buildTextFormField(label: "Bairro", controller: _bairroController),
          buildTextFormField(label: "Cidade", controller: _cidadeController),
          buildTextFormField(label: "Estado", controller: _estadoController),
        ],
      ),
    );
  }

  Widget buildTextFormField({TextEditingController controller, String label}) {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(labelText: label),
      controller: controller,
    );
  }

  // função trocar de tema
  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }

  void changeColor() {
    DynamicTheme.of(context).setThemeData(new ThemeData(
        primaryColor: Theme.of(context).primaryColor == Colors.indigo
            ? Colors.red
            : Colors.indigo));
  }
}
