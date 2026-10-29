import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/constants.dart';

class SidePanel extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: .zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // app name
                Text(
                  appName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'free and open-source',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                    // fontWeight: FontWeight.w600,
                  ),
                ),
                // app version
                Text(
                  appVersion,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // source repository
          ListTile(
            // leading: const Icon(Icons.code_rounded),
            title: const Text('Source Repository'),
            onTap: () => launchUrl(Uri.parse(sourceRepository)),
          ),
          // privacy policy
          ListTile(
            // leading: const Icon(Icons.list_rounded),
            title: const Text('Privacy Policy'),
            onTap: () => launchUrl(Uri.parse(privacyPolicy)),
          ),
          // privacy policy
          ListTile(
            // leading: const Icon(Icons.play),
            title: const Text('Play Store'),
            onTap: () => launchUrl(Uri.parse(playStore)),
          ),
          // developer website
          ListTile(
            // leading: const Icon(Icons.web_rounded),
            title: const Text('Developer Website'),
            onTap: () => launchUrl(Uri.parse(developerWebsite)),
          ),
          // attributions
          ListTile(
            // leading: const Icon(Icons.web_rounded),
            title: const Text('Attributions'),
            subtitle: Column(
              children: [
                ListTile(
                  title: const Text('Podcast Index'),
                  onTap: () => launchUrl(Uri.parse(pcIdxSite)),
                ),
                ListTile(
                  title: const Text('FlatIcon'),
                  onTap: () => launchUrl(Uri.parse(pcIdxSite)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
