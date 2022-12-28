import 'package:cadastro_cerveja/pages/app_page.dart';
import 'package:cadastro_cerveja/supabase_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cadastro_cerveja/supabase_manager.dart';
import 'package:supabase/supabase.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    SupabaseManager supabaseManager = SupabaseManager();

    return Scaffold(
        backgroundColor: Colors.deepPurple,
        body:
        Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  controller: loginController,
                  keyboardType: TextInputType.text,
                  style: new TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                      labelText: 'Login',
                      labelStyle: TextStyle(color: Colors.white, fontSize: 25)
                  ),
                ),
                Divider(),
                TextFormField(
                  autofocus: true,
                  obscureText: true,
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                  style: new TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: TextStyle(color: Colors.white, fontSize: 25)
                  ),
                ),
                Divider(),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: () async {
                    if(await login(supabaseManager))
                      Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => AppPage()));
                    },
                  child: Text(
                    'Entrar',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  Future<bool> login(SupabaseManager supabaseManager) async{
    return await supabaseManager.logar(loginController.text, passwordController.text);
  }
  }

