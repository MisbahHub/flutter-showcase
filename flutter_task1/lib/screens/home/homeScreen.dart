import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Profile Info', style: TextStyle(color: Colors.white))
      ),
      body: Center(
        child: Column(
      mainAxisSize :MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(20)
        ),

        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
           Text('Name : Misbah Nisar', style: TextStyle(color:Colors.white, fontSize:16)),
           Text('Age : 18', style: TextStyle(color: Colors.white, fontSize:16)),
           Text('City: Karachi', style: TextStyle(color: Colors.white, fontSize:16)),
           Text('University : MUET', style: TextStyle(color: Colors.white, fontSize:16)),
          ],
        ),
      ),
        const SizedBox(height: 50),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:  Text('About me clicked'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.brown,
                  ),
                );
              },
              child: const Text('About Me')
          ),
          const SizedBox(width: 15),
          ElevatedButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact clicked'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.brown,
                  ),
                );
              },
              child: const Text('Contact')
          ),
          const SizedBox(width: 15),
          ElevatedButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Skills clicked'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.brown,
                  ),
                );
              },
              child: const Text('Skills'),
          ),

        ]
      )

    ],
        ),
      ),
    );

  }
}
