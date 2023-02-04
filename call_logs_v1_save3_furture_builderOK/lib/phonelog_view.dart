import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';

class PhoneLogView {
  getTitle(CallLogEntry entry) {
    if (entry.name == null) {
      return Text('${entry.number}');
    } else if (entry.name!.isEmpty) {
      return Text('${entry.number}');
    } else {
      return Text('${entry.name}');
    }
  }

  Widget phoneLogView(Future<Iterable<CallLogEntry>> logs) {
    return FutureBuilder(
      future: logs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Iterable<CallLogEntry> entries = <CallLogEntry>[];
          return Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 20.0,
                        child: Text(
                          'MTN',
                          style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: getTitle(entries.elementAt(index)),
                      subtitle: Text('${DateTime.now()} \n 10s'),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone_forwarded),
                        color: Colors.green,
                        onPressed: () {},
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
