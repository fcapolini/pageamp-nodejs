package ub1;

import js.Syntax;

using StringTools;
using ub1.lib.DomTools;


class NodeClient {

	public static function main() {
		var doc = DomTools.domDefaultDoc();
		var pageProps = Syntax.code('window.ub1Props');
		Ub1Client.load(doc, pageProps);
	}

}
