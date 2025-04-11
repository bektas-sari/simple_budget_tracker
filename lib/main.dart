import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Budget Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const BudgetHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BudgetItem {
  final String title;
  final double amount;
  final bool isIncome;

  BudgetItem({
    required this.title,
    required this.amount,
    required this.isIncome,
  });
}

class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  final List<BudgetItem> items = [];

  double get totalBalance {
    double total = 0;
    for (var item in items) {
      total += item.isIncome ? item.amount : -item.amount;
    }
    return total;
  }

  Map<String, double> get pieData {
    double income = 0;
    double expense = 0;

    for (var item in items) {
      if (item.isIncome) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    return {'Income': income, 'Expense': expense};
  }

  void _addNewItem(String title, double amount, bool isIncome) {
    setState(() {
      items.add(BudgetItem(title: title, amount: amount, isIncome: isIncome));
    });
  }

  void _showAddItemSheet() {
    String title = '';
    String amount = '';
    bool isIncome = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (value) => title = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => amount = value,
                  ),
                  Row(
                    children: [
                      const Text('Type: '),
                      const SizedBox(width: 16),
                      DropdownButton<bool>(
                        value: isIncome,
                        items: const [
                          DropdownMenuItem(value: true, child: Text('Income')),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Expense'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              isIncome = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (title.isNotEmpty && double.tryParse(amount) != null) {
                        _addNewItem(title, double.parse(amount), isIncome);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Entry'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Budget Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Balance: \$${totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                dataMap: pieData,
                chartRadius: 150,
                chartType: ChartType.ring,
                animationDuration: const Duration(milliseconds: 800),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValues: true,
                ),
                legendOptions: const LegendOptions(
                  legendPosition: LegendPosition.bottom,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(
                    item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: item.isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(item.title),
                  trailing: Text(
                    '\$${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: item.isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
