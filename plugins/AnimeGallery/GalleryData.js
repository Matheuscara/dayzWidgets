.pragma library

function fileUrl(path) {
    return "file://" + path.split("/").map(encodeURIComponent).join("/");
}

function parseManifest(text) {
    const document = JSON.parse(text);
    if (!document || !Array.isArray(document.images))
        throw new Error("O manifesto precisa de uma lista images.");
    return document.images.filter(item => item && typeof item.file === "string"
        && item.file.length > 0 && !item.file.startsWith("/")
        && !item.file.split("/").some(part => part === "..")
        && item.file.indexOf("\0") === -1).map(item => ({
            file: item.file,
            collection: typeof item.collection === "string" ? item.collection : "Minha coleção",
            width: Number(item.width) > 0 ? Number(item.width) : 0,
            height: Number(item.height) > 0 ? Number(item.height) : 0
        }));
}
