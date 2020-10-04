async function writeImage(blob) {
  return navigator.clipboard.write([new ClipboardItem({ 'image/png': blob })])
}

async function readImage(blob) {
  let items = await navigator.clipboard.read()
  for (let i = 0; i < items.length; i++) {
    if (items[i].types == 'image/png') {
      const blob = items[i].getType('image/png');
      return blob;
    }
  }
  return null;
}
