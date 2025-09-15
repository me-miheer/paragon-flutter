import 'package:flutter/material.dart';

class DetailTable extends StatefulWidget {
  const DetailTable({super.key});

  @override
  State<DetailTable> createState() => _DetailTableState();
}

class _DetailTableState extends State<DetailTable> {
  final TextEditingController _searchController = TextEditingController();

  // Sample Data
  final List<List<String>> _data = [
    ["EEVGI2131-BGE", "1201A", "1", "Scheme 1", "Carton"],
    ["EEVGI2131-BGE", "0609B", "2", "Scheme 1", "Carton"],
    ["EEVGI2131-BGE", "0901A", "2", "Scheme 2", "Box"],
    ["EEVGI2131-BGE", "0911A", "1", "Scheme 1", "Carton"],
  ];

  String _searchQuery = "";
  String? _selectedScheme;

  @override
  Widget build(BuildContext context) {
    // Apply filters
    final List<List<String>> filteredData = _data.where((row) {
      final matchesSearch = row.any(
          (cell) => cell.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesScheme =
          _selectedScheme == null || row[3] == _selectedScheme;
      return matchesSearch && matchesScheme;
    }).toList();

    // Unique scheme values
    final schemes = _data.map((row) => row[3]).toSet().toList();

    return Column(
      children: [
        // 🔎 Search & Scheme Filter Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Search
              Expanded(
                flex: 2,
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
              const SizedBox(width: 8),

              // Scheme Filter
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _selectedScheme,
                  hint: const Text("Scheme"),
                  isDense: true,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedScheme = value;
                    });
                  },
                  items: schemes
                      .map((scheme) => DropdownMenuItem(
                            value: scheme,
                            child: Text(scheme),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // 📋 Table
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
                          DataCell(Text(row[0])),
                          DataCell(Text(row[1])),
                          DataCell(Text(row[2])),
                          DataCell(Text(row[4])),
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
