package ub1;

import js.node.Fs;
import js.node.Http;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;
import ub1.lib.Url;

using StringTools;


class NodeServer {

	public static function main() {
		var server = Http.createServer((req:IncomingMessage, res:ServerResponse) -> {
			var root = Sys.getCwd();
			var domain = req.headers.get('host');
			var url = new Url(req.url);
			var path = url.path;
			path.endsWith('/') ? path = path.substr(0, path.length - 1) : null;
			var re = ~/^[^\.]+\.(.+)$/;
			var ext = re.match(path) ? re.matched(1) : null;
			if (ext == null) {
				/*if (isFile(root + path + '.html')) {
					path = path + '.html';
				} else*/ if (isDirectory(root + path)) {
					path = path + '/index.html';
				} else {
					path = path + '.html';
				}
			}
			try {
				var page = Ub1Server.load(root, path, domain, true);
				res.writeHead(200, {"Content-Type": "text/html"});
				res.end(page.doc.toString());
			} catch (ex:Dynamic) {
				res.writeHead(500, {"Content-Type": "text/plain"});
				res.end('' + ex);
			}
		});
		server.listen(3000);
	}

	static inline function isFile(path:String) {
		try {
			return Fs.statSync(path).isFile();
		} catch (ex:Dynamic) {
			return false;
		}
	}

	static inline function isDirectory(path:String) {
		try {
			return Fs.statSync(path).isDirectory();
		} catch (ex:Dynamic) {
			return false;
		}
	}

}
