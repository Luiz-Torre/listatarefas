import 'dart:io';
import "dart:async";
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  TextEditingController _controllerTarefa = TextEditingController();
  TextEditingController _controllerEditar = TextEditingController();

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/data.json");
  }

  _saveTarefa() {
    String taskStr = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = taskStr;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });
    _saveFile();
  }

  _saveFile() async {
    final file = await _getFile();
    String data = jsonEncode(_listaTarefas);
    file.writeAsString(data);
  }

  _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget listItemCreate(BuildContext context, int index) {
    final item = _listaTarefas[index]["titulo"] +
        _listaTarefas[index]["realizada"].toString();
    var _lastRemovedTask;

    return Dismissible(
        key: Key(item),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Tela de confirmação"),
                  content: const Text("Tem certeza que deseja excluir?"),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          _listaTarefas.removeAt(index);

                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Aceito Deletar")),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancelar"),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Atualizar Tarefa"),
                    content: TextField(
                        controller: _controllerEditar,
                        decoration:
                            InputDecoration(labelText: "atualização da tarefa"),
                        onChanged: (text) {}),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancelar")),
                      TextButton(
                          onPressed: () {
                            _listaTarefas[index]["titulo"] = _controllerEditar.text;
                            Navigator.pop(context);
                            setState(() {
                              
                            });
                          },
                          child: Text("Salvar")),
                    ],
                  );
                });
          }
        },
        secondaryBackground: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ]),
        ),
        background: Container(
          color: Colors.green,
          padding: EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
              Icons.edit,
              color: Colors.white,
            )
          ]),
        ),
        child: CheckboxListTile(
          title: Text(_listaTarefas[index]["titulo"]),
          value: _listaTarefas[index]["realizada"],
          onChanged: (newVal) {
            setState(() {
              _listaTarefas[index]["realizada"] = newVal;
            });
            _saveFile();
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    _readFile().then((data) {
      setState(() {
        print("Data: $data");
        _listaTarefas = jsonDecode(data);
        print("Data2: $_listaTarefas");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("items:" + _listaTarefas.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Color.fromARGB(255, 36, 36, 42),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 36, 36, 42),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                      controller: _controllerTarefa,
                      decoration:
                          InputDecoration(labelText: "Digite sua tarefa"),
                      onChanged: (text) {}),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancelar")),
                    TextButton(
                        onPressed: () {
                          _saveTarefa();
                          Navigator.pop(context);
                        },
                        child: Text("Salvar")),
                  ],
                );
              });
        },
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaTarefas.length, itemBuilder: listItemCreate))
        ]),
      ),
    );
  }
}
