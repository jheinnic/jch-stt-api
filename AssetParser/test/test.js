const fs = require('fs');
const pngjs = require('pngjs');
var parser = require('./../src/index');

function writePNG(rawBitmap, width, height) {
	var png = new pngjs.PNG({ width, height });
	png.data = rawBitmap;
	return pngjs.PNG.sync.write(png);
}

fs.readFile('./test/testsprites.sd', function (err, data) {
    if (err) {
        console.error(err);
        return;
    }

    var result = parser.parseAssetBundle(data);
    console.assert(result.sprites.length == 4);
    console.assert(result.sprites[0].spriteName == "icon_holodisc");
    console.assert(result.sprites[0].spriteBitmap.data.length == 227424);

    /*let pngImage = writePNG(result.imageBitmap.data, result.imageBitmap.width, result.imageBitmap.height);
    fs.writeFileSync('./test/' + result.imageName + '.png', pngImage);
    
    result.sprites.forEach(sprite=> {
        let pngImage = writePNG(sprite.spriteBitmap.data, sprite.spriteBitmap.width, sprite.spriteBitmap.height);
        fs.writeFileSync('./test/' + sprite.spriteName + '.png', pngImage);
    });*/
});

fs.readFile('./test/test.sd', function (err, data) {
    if (err) {
        console.error(err);
        return;
    }

    var result = parser.parseAssetBundle(data);
    console.assert(result.imageName == "cm_mirroruhura_icon");
    console.assert(result.sprites.length == 0);
    console.assert(result.imageBitmap.width == 128);
    console.assert(result.imageBitmap.height == 128);

	/*let pngImage = writePNG(result.imageBitmap.data, result.imageBitmap.width, result.imageBitmap.height);
	fs.writeFileSync('./test/' + result.imageName + '.png', pngImage);*/
});