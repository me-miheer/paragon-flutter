import 'package:flutter/material.dart';

class DetailTable extends StatefulWidget {
  final List<Map<String, dynamic>> data; // ✅ Accept dynamic data
  const DetailTable(this.data, {super.key});

  @override
  State<DetailTable> createState() => _DetailTableState();
}

class _DetailTableState extends State<DetailTable> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Apply search filter only
    final List<Map<String, dynamic>> filteredData = widget.data.where((row) {
      return row.values.any((cell) =>
          cell.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Column(
      children: [
        // 🔎 Search box only
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 18),
              hintText: "Search...",
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // 📋 Table
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical, // only vertical scroll
            child: SizedBox(
              width: double.infinity, // ✅ full available width
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.teal.shade600),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                columnSpacing: 32,
                dataTextStyle: const TextStyle(fontSize: 13),
                columns: const [
                  DataColumn(label: Text("ARTICLE")),
                  DataColumn(label: Text("SIZE")),
                  DataColumn(label: Text("QTY")),
                  DataColumn(label: Text("UNIT")),
                ],
                rows: filteredData
                    .map(
                      (row) => DataRow(
                    cells: [
                      DataCell(Text(row["qr"] ?? "")),
                      DataCell(Text(row["consumer_size"] ?? "")),
                      DataCell(Text(row["quantity"] ?? "")),
                      DataCell(Text(row["type"] ?? "")),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

