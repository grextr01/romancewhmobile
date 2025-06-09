import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:romancewhs/Bloc/Trx_Details_bloc/trx_details_page_bloc.dart';
import 'package:romancewhs/UX/Api.dart';
import 'package:romancewhs/main.dart';
import '../../UX/Theme.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage(
      {super.key, required this.transactions, required this.trxCode});
  final List transactions;
  final String trxCode;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController transactionTypeController =
      TextEditingController();
  List transactions = [];
  API api = API();

  @override
  void initState() {
    transactions = [...widget.transactions];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: secondaryColor,
          shadowColor: const Color.fromRGBO(206, 206, 206, 100),
          title: const Text(
            'Transactions',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              controller: transactionTypeController,
              onChanged: (value) {
                transactions = widget.transactions.where((element) {
                  return element['CONS_BILLING_NUMBER']
                      .toString()
                      .toLowerCase()
                      .contains(value.toLowerCase());
                }).toList();
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Trx Number..',
                contentPadding: const EdgeInsets.only(left: 12),
                suffix: IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () {
                    transactionTypeController.clear();
                    transactions = [...widget.transactions];
                    setState(() {});
                  },
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return Material(
                    child: GestureDetector(
                      onLongPressStart: (details) async {
                        final screenWidth = MediaQuery.of(context).size.width;
                        const menuWidth = 150.0;
                        final dx = screenWidth - menuWidth - 10;
                        final dy = details.globalPosition.dy;

                        final selected = await showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            dx,
                            dy,
                            0,
                            0,
                          ),
                          items: [
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        );
                        if (selected == 'delete') {
                          submitTransaction(
                              transactions[index]['TRX_HEADER_ID'].toString());
                        }
                      },
                      child: InkWell(
                        onTap: () async {
                          mainNavigatorKey.currentState!.push(MaterialPageRoute(
                              builder: (_) => TrxDetailsBlocPage(
                                    headerId: transactions[index]
                                        ['TRX_HEADER_ID'],
                                    trxHeader: transactions[index],
                                    trxCode: widget.trxCode,
                                    onSubmit: (headerId) {
                                      transactions.removeWhere((transaction) =>
                                          transaction['TRX_HEADER_ID']
                                              .toString() ==
                                          headerId);
                                      setState(() {});
                                    },
                                  )));
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 15, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(
                                  text: 'Transaction Number: ',
                                  style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700),
                                  children: [
                                    TextSpan(
                                        text: transactions[index]
                                                ['CONS_BILLING_NUMBER']
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal))
                                  ])),
                              Text.rich(TextSpan(
                                  text: transactions[index]['CUSTOMER_NAME'] !=
                                          null
                                      ? 'Customer: '
                                      : 'Trsf Number: ',
                                  style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700),
                                  children: [
                                    TextSpan(
                                        text: transactions[index]
                                                    ['CUSTOMER_NAME'] !=
                                                null
                                            ? transactions[index]
                                                    ['CUSTOMER_NAME']
                                                .toString()
                                            : transactions[index]
                                                    ['CUSTOMER_NUMBER']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal))
                                  ])),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ));
  }

  Future<bool> submitTransaction(String headerId) async {
    var response = await api.getApiToMap(
        api.apiBaseUrl, '/Warehouse/romance/update-erp/$headerId', 'post');
    if (response['statusCode'] == 200) {
      transactions.removeWhere(
          (transaction) => transaction['TRX_HEADER_ID'].toString() == headerId);
      setState(() {});
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Transaction submitted successfully.'),
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
      return true;
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
                'Error submitting transaction. Kindly Contact your IT.'),
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
      return false;
    }
  }
}
