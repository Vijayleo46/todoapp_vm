import 'package:flutter/material.dart';
import 'package:todoapp_vm/sql_help.dart';
class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);
  @override
  State<TodoApp> createState() => _TodoAppState();
}
 class _TodoAppState extends State<TodoApp>{


   final _formKey = GlobalKey<FormState>();   // All journals
   List<Map<String, dynamic>> _journals = [];

   bool _isLoading = true;
   // This function is used to fetch all data from the database
   void _refreshJournals() async {
     final data = await SQLHelper.getItems();
     setState(() {
       _journals = data;
       _isLoading = false;
     });
   }

   @override
   void initState() {
     super.initState();
     _refreshJournals(); // Loading the diary when the app starts
   }

   final TextEditingController _titleController = TextEditingController();
   final TextEditingController _descriptionController = TextEditingController();

   // This function will be triggered when the floating button is pressed
   // It will also be triggered when you want to update an item
   void _showForm(int? id) async {
     if (id != null) {
       // id == null -> create new item
       // id != null -> update an existing item
       final existingJournal =
       _journals.firstWhere((element) => element['id'] == id);
       _titleController.text = existingJournal['title'];
       _descriptionController.text = existingJournal['description'];
     }
     showModalBottomSheet(
         context: context,
         elevation: 5,
         isScrollControlled: true,
         builder: (_) => Container(
           padding: EdgeInsets.only(
             top: 15,
             left: 15,
             right: 15,
             // this will prevent the soft keyboard from covering the text fields
             bottom: MediaQuery.of(context).viewInsets.bottom + 120,
           ),
           child: Form(
             key:
             _formKey,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 TextFormField(
                   validator: (value) {
                     if(value!.isEmpty){
                       return 'Enter Title';
                     }
                     return null;
                   },
                   controller: _titleController,
                   decoration: const InputDecoration(hintText: 'Title'),
                 ),
                 const SizedBox(
                   height: 10,
                 ),
                TextFormField(
                  validator: (value) {
                    if(value!.isEmpty){
                      return 'Enter Descrption';
                    }
                    return null;
                  },
                   controller: _descriptionController,
                   decoration: const InputDecoration(hintText: 'Description'),
                 ),
                 const SizedBox(
                   height: 20,
                 ),
                 ElevatedButton(
                   onPressed: () async {
                     // Save new journal

                     if(_formKey.currentState!.validate())
                       {
                         if (id == null) {
                           await _addItem();
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Successfully Saved')),
                           );

                           Navigator.of(context).pop();
                         }

                       }


                     if (id != null) {
                       await _updateItem(id);
                       Navigator.of(context).pop();
                     }

                     // Clear the text fields
                     _titleController.text = '';
                     _descriptionController.text = '';

                     // Close the bottom sheet
                    // Navigator.of(context).pop();
                   },
                   child: Text(id == null ? 'Create New' : 'Update'),
                 )
               ],
             ),
           ),
         ));
   }

// Insert a new journal to the database
   Future<void> _addItem() async {
     await SQLHelper.createItem(
         _titleController.text, _descriptionController.text);
     _refreshJournals();
   }

   // Update an existing journal
   Future<void> _updateItem(int id) async {
     await SQLHelper.updateItem(
         id, _titleController.text, _descriptionController.text);
     _refreshJournals();
   }

   // Delete an item
   void _deleteItem(int id) async {
     await SQLHelper.deleteItem(id);
     // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
     //   content: Text("Successfully deleted a journal!"));
     showDialog<void>(
     context: context,
     barrierDismissible: false,// user must tap button!
     builder: (BuildContext context) {
     return AlertDialog(
     title: const Text('AlertDialog Title'),
     content: SingleChildScrollView(
     child: ListBody(
     children: <Widget>[
     Text('This is a demo alert dialog.'),
     Text('Would you like to approve of this message?'),
     ],
     ),
     ),
     actions: <Widget>[
     TextButton(
     child: const Text('Approve'),
     onPressed: () {
     Navigator.of(context).pop();
     },
     ),
     ],
     );
     },


   );
     _refreshJournals();
   }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         backgroundColor: Colors.yellow,
         title: const Text('Todo.com',
         style: TextStyle(
           fontFamily: "Fasthand"
         ),),
       ),
       body: _isLoading
           ? const Center(
         child: CircularProgressIndicator(),
       )
           : ListView.builder(
         itemCount: _journals.length,
         itemBuilder: (context, index) => Card(
           color: Color.fromRGBO( 255, 204, 204, 1.0),
           margin: const EdgeInsets.all(15),
           child: ListTile(
               title: Text(_journals[index]['title'], style: TextStyle(
                 fontFamily: "Fasthand",
                 fontSize: 20
               ),),
               subtitle: Text(_journals[index]['description'],
               style: TextStyle(
                 fontFamily: "Fasthand",
                 fontWeight: FontWeight.w500,
                 fontStyle: FontStyle.italic
               ),),
               trailing: SizedBox(
                 width: 100,
                 child: Row(
                   children: [
                     IconButton(
                       icon: const Icon(Icons.edit),
                       onPressed: () => _showForm(_journals[index]['id']),
                     ),
                     IconButton(
                       icon: const Icon(Icons.delete),
                       onPressed: () =>
                           _deleteItem(_journals[index]['id']),
                     ),
                   ],
                 ),
               )),
         ),
       ),
       floatingActionButton: FloatingActionButton(
         child: const Icon(Icons.add),
         onPressed: () => _showForm(null),
       ),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
     );
   }
 }