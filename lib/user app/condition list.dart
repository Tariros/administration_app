import 'package:flutter/material.dart';
import 'package:administration_application/entities/Remedies/category.entity.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/entities/Health Issues/condition.entity.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikipedia/wikipedia.dart';
import 'package:administration_application/user app/RemedyPlansPage.dart';


class ConditionList extends StatefulWidget {
  @override
  _ConditionListState createState() => _ConditionListState();
}

class _ConditionListState extends State<ConditionList> {
  late final Box<Conditions> _conditionBox;
  List<Conditions> _conditions = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
    _loadData();
  }

  Future<void> _loadData() async {

    _conditions = _conditionBox.getAll()..sort((a, b) => a.name.compareTo(b.name));
    setState(() {});

  }

  void _viewCondition(Conditions condition) {
    // Navigate to the ConditionScreen with the selected item's data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConditionScreen(condition: condition),
      ),
    );
  }

  void _filterConditions(String query) {
    final lowercaseQuery = query.toLowerCase();
    final filteredConditions = _conditionBox.getAll().where((condition) {
    final lowercaseName = condition.name.toLowerCase();
    return lowercaseName.contains(lowercaseQuery);
  }).toList();
  setState(() {
    _conditions = filteredConditions;
  });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Adjust the height as needed
        child: AppBar(
          elevation: 0, // Remove shadow effect
          backgroundColor: Colors.black, // Background color

          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Conditions',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.white, // Title text color
                    fontSize: 30, // Adjust the font size as needed
                  ),
                ),
              ),
            ],
          ),
          centerTitle: false,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white, // Back button color
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _filterConditions(query);
              },
              decoration: InputDecoration(
                labelText: 'Search Conditions',
                hintText: 'Enter a condition name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),

                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conditions.length,
              itemBuilder: (BuildContext context, int index) {
                final condition = _conditions[index];
                return Container (
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Background color
                    borderRadius: BorderRadius.circular(32), // Rounded corners
                  ),
                  child: ListTile(
                    title: Text(condition.name,
                      style: TextStyle(
                        color: Colors.black54, // Text color
                        fontWeight: FontWeight.bold,
                      ),

                    ),
                    subtitle: Text(condition.description,
                      style: TextStyle(color: Colors.black54),),
                    onTap: () {
                      // Open the ItemScreen when tapped
                      _viewCondition(condition);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConditionScreen extends StatefulWidget {
  final Conditions condition;


  const ConditionScreen({Key? key, required this.condition}) : super(key: key);

  @override
  _ConditionScreenState createState() => _ConditionScreenState();
}

class _ConditionScreenState extends State<ConditionScreen> {
  String selectedTab = 'Information';

  bool _loading = false;
  List<WikipediaSearch> _data = [];


  @override
  void initState() {
    super.initState();
    getWikipediaData();
  }

  Future<void> getWikipediaData() async {
    try {
      setState(() {
        _loading = true;
      });
      Wikipedia instance = Wikipedia();
      // Replace 'Flutter' with the condition name you want to search for
      var result = await instance.searchQuery(searchQuery: '${widget.condition.name}', limit: 10);
      setState(() {
        _loading = false;
        _data = result!.query!.search!;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Adjust the height as needed
    child: AppBar(
    elevation: 0, // Remove shadow effect
    backgroundColor: Colors.black, // Background color

    title: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(widget.condition.name,
        style: GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.white, // Title text color
        fontSize: 30, // Adjust the font size as needed
      ),
    ),
    ),
        ],
      ),
      centerTitle: false,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white, // Back button color
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
    ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [

                Text( 'Descroption: ${widget.condition.description}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTabButton('Wikipedia', Icons.info_outline),
              buildTabButton('Causes', Icons.medical_information_outlined),
              buildTabButton('Complications', Icons.warning_amber),
              buildTabButton('Remedies', Icons.warning_amber),
            ],
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildSelectedTabContent(),
            ),
          ),
        ],
      ),

    );
  }

  Widget buildTabButton(String tabName, IconData iconData) {
    bool isSelected = selectedTab == tabName;
    Color? iconColor = Colors.white;

    if (isSelected) {
      switch (tabName) {
        case 'Information':
          iconColor = Colors.green[300];
          break;

  case 'Causes':
          iconColor = Colors.blue[300];
          break;
        case 'Complications':
          iconColor = Colors.red[300];
          break;
        case 'Remedies':
          iconColor = Colors.pink[300];
          break;
        case 'Wikipedia':
          iconColor = Colors.indigo;
        default:
          break;
      }
    }

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = isSelected ? '' : tabName;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isSelected ? iconColor : Colors.grey,
            child: Icon(
              iconData,
              color: isSelected ? Colors.white : iconColor,
            ),
          ),
          Visibility(
            visible: isSelected,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(tabName),
            ),
          ),
        ],
      ),
    );
  }
  


  Widget _buildWikipediaContent() {
    return Stack(
      children: [
        ListView.builder(
          itemCount: _data.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) => InkWell(
            onTap: () async {
              Wikipedia instance = Wikipedia();
              setState(() {
                _loading = true;
              });
              var pageData = await instance.searchSummaryWithPageId(pageId: _data[index].pageid!);

              setState(() {
                _loading = false;
              });
              if (pageData == null) {
                const snackBar = SnackBar(
                  content: Text('Data Not Found'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
                    appBar: AppBar(
                      title: Text(_data[index].title!, style: const TextStyle(color: Colors.black)),
                      backgroundColor: Colors.white,
                      iconTheme: const IconThemeData(color: Colors.black),
                    ),
                    body: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        Text(pageData.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

                        const SizedBox(height: 8),
                        Text(pageData.description!, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        Text(pageData.extract!)
                      ],
                    ),
                  ),
                );
              }
            },
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(_data[index].title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    Text(_data[index].snippet!),
                  ],
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: _loading,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }


  Widget buildSelectedTabContent() {
    switch (selectedTab) {
      case 'Wikipedia':
        return  _buildWikipediaContent();
      case 'Causes':
        return Text('Causes:\n${widget.condition.causes}');
      case 'Complications':
        return Text('Complications:\n${widget.condition.complications}');

      case 'Remedies':
        final items = <String>[];
        for (final plan in widget.condition.plan) {
          final item = plan.Item.target;
          if (item != null) {
            items.add(item.name);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remedies:'),
            for (final item in items)
              InkWell(
                onTap: () {
                  var plan;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlanScreen(plan:plan),
                    ),
                  );
                },
                child: Text('$item'),
              ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}


