.pragma library

function read(data, home) {
    let items = data.shortcuts;
    if (data.shortcutsJson && String(data.shortcutsJson).trim()) {
        try {
            items = JSON.parse(data.shortcutsJson);
            if (!Array.isArray(items))
                throw new Error("Lista JSON esperada");
        } catch (_) {
            return {items: [], error: "JSON de atalhos inválido: revise as configurações do plugin."};
        }
    }
    if (items === undefined || items === null) {
        items = [
            {name: "Arquivos", icon: "folder_open", url: "file://" + home.split("/").map(encodeURIComponent).join("/")},
            {name: "Notas rápidas", icon: "edit_note", command: ["dms", "ipc", "notepad", "toggle"]},
            {name: "Configurações", icon: "settings", command: ["dms", "ipc", "settings", "open"]}
        ];
        if (data.terminal)
            items.push({name: "Terminal", icon: "terminal", command: [String(data.terminal)]});
        if (data.editor)
            items.push({name: "Editor", icon: "code", command: [String(data.editor)]});
    }
    if (!Array.isArray(items) || !items.every(item => item && typeof item.name === "string"
        && typeof item.icon === "string" && ((typeof item.url === "string" && /^(file|https?):/.test(item.url))
        || (Array.isArray(item.command) && item.command.length > 0
        && item.command.every(part => typeof part === "string" && part.indexOf("\0") === -1)
        && item.command[0].trim() !== ""))))
        return {items: [], error: "Atalhos precisam de nome, ícone e lista command ou URL file/http(s)."};
    return {items: items, error: ""};
}
