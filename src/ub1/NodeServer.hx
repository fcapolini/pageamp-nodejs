package ub1;

import js.node.Fs;
import js.node.Http;
import js.node.Path;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;

using StringTools;
using ub1.lib.PropertyTools;


class NodeServer {

	public static function main() {
		var server = Http.createServer((req:IncomingMessage, res:ServerResponse) -> {
			filter(req, (redirectPath) -> {
				res.statusCode=302;
				res.setHeader('Location', redirectPath);
				res.end();
			}, (root, dirPath, domain) -> {
				servePage(root, dirPath + 'index.html', domain, res);
			}, (root, filePath, fileExt, domain) -> {
				fileExt == '' ? filePath += (fileExt = '.html') : null;
				if (fileExt == '.html') {
					servePage(root, filePath, domain, res);
				} else if (fileExt == '.htm' || filePath.toLowerCase() == '/index.js') {
					res.statusCode = 404;
					res.end('File ${filePath} not found!');
				} else {
					serveFile(filePath, fileExt, res);
				}
			});
		});
		server.listen(3000);
	}

	static function servePage(root:String, path:String, domain:String, res:ServerResponse) {
		try {
			//TODO: async Ub1Server.load()
			var page = Ub1Server.load(root, path, domain, true);
			res.writeHead(200, {"Content-Type": "text/html"});
			res.end(page.doc.toString());
		} catch (ex:Dynamic) {
			res.writeHead(500, {"Content-Type": "text/plain"});
			res.end('' + ex);
		}
	}

	//TODO: limit memory usage
	// https://stackoverflow.com/a/29046869/12573599
	static function serveFile(path:String, ext:String, res:ServerResponse) {
		Fs.readFile('.${path}', (err, data) -> {
			if (err != null) {
				res.statusCode = 404;
				res.end('File ${path} not found!');
			} else {
				res.setHeader('Content-Type', MIMETYPES.get(ext, 'text/plain'));
				res.end(data);
			}
		});
	}

	// ===================================================================================
	// util
	// ===================================================================================
	static var MIMETYPES = {
		'.ico': 'image/x-icon',
		'.html': 'text/html',
		'.js': 'application/javascript',
		'.json': 'application/json',
		'.css': 'text/css',
		'.png': 'image/png',
		'.jpg': 'image/jpeg',
		'.wav': 'audio/wav',
		'.mp3': 'audio/mpeg',
		'.svg': 'image/svg+xml',
		'.pdf': 'application/pdf',
		'.doc': 'application/msword'	
	};
	
	static function filter(req:IncomingMessage,
			onRedirect:String->Void,
			onServeDir:String->String->String->Void,
			onServeFile:String->String->String->String->Void) {
		var url = req.url;
		var ext = Path.parse(url).ext.toLowerCase();
		needsRedirect(url, ext, (shouldRedirect) -> {
			if (shouldRedirect) {
				onRedirect(url + '/');
			} else {
				var root = Sys.getCwd();
				var domain:String = req.headers.get('host');
				if (url.endsWith('/')) {
					onServeDir(root, url, domain);
				} else {
					onServeFile(root, url, ext, domain);
				}
			}
		});
	}

	static function needsRedirect(path:String, ext:String, cb:Bool->Void) {
		if (ext == '' && !path.endsWith('/')) {
			checkDir('.$path', cb);
		} else {
			cb(false);
		}
	}

	static function checkDir(path:String, cb:Bool->Void) {
		Fs.stat(path, (err, stats) -> cb(err == null && stats.isDirectory()));
	}

}
