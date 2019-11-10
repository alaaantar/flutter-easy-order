import 'package:meta/meta.dart';

class Storage {
  String url;
  String path;

  Storage({@required this.url, @required this.path})
      : assert(url != null && path != null);

  Map<String, dynamic> toJson() => {
        'url': this.url,
        'path': this.path,
      };

  Storage.fromJson(Map<String, dynamic> json)
      : url = json['url'],
        path = json['path'];

  Storage.clone(Storage storage)
      : url = storage.url,
        path = storage.path;

  @override
  String toString() {
    return 'Storage{url: $url, path: $path}';
  }
}
