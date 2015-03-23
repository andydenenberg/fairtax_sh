/* Modernizr 2.5.3 (Custom Build) | MIT & BSD
 * Build: http://www.modernizr.com/download/#-geolocation-shiv-cssclasses
 */
window.Modernizr=function(a,b,c){function d(a){o.cssText=a}function e(a,b){return d(prefixes.join(a+";")+(b||""))}function f(a,b){return typeof a===b}function g(a,b){return!!~(""+a).indexOf(b)}function h(a,b,d){for(var e in a){var g=b[a[e]];if(g!==c)return d===!1?a[e]:f(g,"function")?g.bind(d||b):g}return!1}var i="2.5.3",j={},k=!0,l=b.documentElement,m="modernizr",n=b.createElement(m),o=n.style,p,q={}.toString,r={},s={},t={},u=[],v=u.slice,w,x={}.hasOwnProperty,y;!f(x,"undefined")&&!f(x.call,"undefined")?y=function(a,b){return x.call(a,b)}:y=function(a,b){return b in a&&f(a.constructor.prototype[b],"undefined")},Function.prototype.bind||(Function.prototype.bind=function(a){var b=this;if(typeof b!="function")throw new TypeError;var c=v.call(arguments,1),d=function(){if(this instanceof d){var e=function(){};e.prototype=b.prototype;var f=new e,g=b.apply(f,c.concat(v.call(arguments)));return Object(g)===g?g:f}return b.apply(a,c.concat(v.call(arguments)))};return d}),r.geolocation=function(){return!!navigator.geolocation};for(var z in r)y(r,z)&&(w=z.toLowerCase(),j[w]=r[z](),u.push((j[w]?"":"no-")+w));return d(""),n=p=null,function(a,b){function c(a,b){var c=a.createElement("p"),d=a.getElementsByTagName("head")[0]||a.documentElement;return c.innerHTML="x<style>"+b+"</style>",d.insertBefore(c.lastChild,d.firstChild)}function d(){var a=k.elements;return typeof a=="string"?a.split(" "):a}function e(a){var b={},c=a.createElement,e=a.createDocumentFragment,f=e();a.createElement=function(a){var d=(b[a]||(b[a]=c(a))).cloneNode();return k.shivMethods&&d.canHaveChildren&&!h.test(a)?f.appendChild(d):d},a.createDocumentFragment=Function("h,f","return function(){var n=f.cloneNode(),c=n.createElement;h.shivMethods&&("+d().join().replace(/\w+/g,function(a){return b[a]=c(a),f.createElement(a),'c("'+a+'")'})+");return n}")(k,f)}function f(a){var b;return a.documentShived?a:(k.shivCSS&&!i&&(b=!!c(a,"article,aside,details,figcaption,figure,footer,header,hgroup,nav,section{display:block}audio{display:none}canvas,video{display:inline-block;*display:inline;*zoom:1}[hidden]{display:none}audio[controls]{display:inline-block;*display:inline;*zoom:1}mark{background:#FF0;color:#000}")),j||(b=!e(a)),b&&(a.documentShived=b),a)}var g=a.html5||{},h=/^<|^(?:button|form|map|select|textarea)$/i,i,j;(function(){var a=b.createElement("a");a.innerHTML="<xyz></xyz>",i="hidden"in a,j=a.childNodes.length==1||function(){try{b.createElement("a")}catch(a){return!0}var c=b.createDocumentFragment();return typeof c.cloneNode=="undefined"||typeof c.createDocumentFragment=="undefined"||typeof c.createElement=="undefined"}()})();var k={elements:g.elements||"abbr article aside audio bdi canvas data datalist details figcaption figure footer header hgroup mark meter nav output progress section summary time video",shivCSS:g.shivCSS!==!1,shivMethods:g.shivMethods!==!1,type:"default",shivDocument:f};a.html5=k,f(b)}(this,b),j._version=i,l.className=l.className.replace(/(^|\s)no-js(\s|$)/,"$1$2")+(k?" js "+u.join(" "):""),j}(this,this.document);