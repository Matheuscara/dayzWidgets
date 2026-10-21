.pragma library

function argv(value) {
    return Array.isArray(value) && value.length > 0
        && value.every(part => typeof part === "string" && part.indexOf("\0") === -1)
        && value[0].trim() !== "";
}

function defaults() {
    return [
        {name: "Notas rápidas", desc: "Bloco de notas do DMS", icon: "edit_note", category: "util", kind: "native", ipc: ["notepad", "toggle"]},
        {name: "Plugins", desc: "Configurar plugins do DMS", icon: "extension", category: "system", kind: "native", ipc: ["settings", "openWith", "plugins"]},
        {name: "Configurações", desc: "Preferências do DMS", icon: "settings", category: "system", kind: "native", ipc: ["settings", "open"]}
    ];
}

function validTool(tool) {
    if (!tool || typeof tool.name !== "string" || !tool.name.trim())
        return false;
    if (["native", "plugin", "widget", "desktop", "app"].indexOf(tool.kind) === -1)
        return false;
    if (["plugin", "widget", "desktop"].indexOf(tool.kind) !== -1
        && (typeof tool.target !== "string" || !tool.target.trim()))
        return false;
    return argv(tool.kind === "app" ? tool.command : tool.ipc);
}

function readTools(data) {
    let items = data.tools;
    if (data.toolsJson && String(data.toolsJson).trim()) {
        try {
            items = JSON.parse(data.toolsJson);
            if (!Array.isArray(items))
                throw new Error("Lista JSON esperada");
        } catch (_) {
            return {items: [], error: "JSON inválido: revise as ferramentas nas configurações do plugin."};
        }
    }
    if (items === undefined || items === null)
        return {items: defaults(), error: ""};
    if (!Array.isArray(items) || !items.every(validTool))
        return {items: [], error: "Cada ferramenta precisa de nome, tipo e uma lista de argumentos válida."};
    return {items: items.map(tool => Object.assign({desc: "", keywords: "", icon: "apps", category: "util"}, tool)), error: ""};
}
