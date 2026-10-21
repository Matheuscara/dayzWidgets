import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "GalleryData.js" as GalleryData

DesktopPluginComponent {
    id: root
    minWidth: 260
    minHeight: 170

    readonly property string directory: pluginData.directory || (Quickshell.env("HOME") + "/Pictures/Wallpapers")
    readonly property string manifestPath: pluginData.manifestPath || ""
    property var folderPictures: []
    property var manifestPictures: []
    property string loadError: ""
    readonly property var pictures: manifestPath ? manifestPictures : folderPictures
    property int currentIndex: 0
    readonly property var current: pictures.length ? pictures[currentIndex % pictures.length] : null
    onPicturesChanged: currentIndex = 0
    onManifestPathChanged: {
        manifestPictures = [];
        loadError = "";
    }

    function updateFolder() {
        const images = [];
        if (folderModel.status === FolderListModel.Ready) {
            for (let i = 0; i < folderModel.count; i++)
                images.push({file: folderModel.get(i, "fileName"), collection: "Minha coleção", width: 0, height: 0});
        }
        folderPictures = images;
    }

    FolderListModel {
        id: folderModel
        folder: root.manifestPath ? "" : GalleryData.fileUrl(root.directory)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif", "*.bmp"]
        showDirs: false
        showHidden: false
        caseSensitive: false
        sortField: FolderListModel.Name
        onStatusChanged: root.updateFolder()
        onCountChanged: root.updateFolder()
        onFolderChanged: root.folderPictures = []
    }

    FileView {
        path: root.manifestPath
        watchChanges: true
        onLoaded: {
            try {
                root.manifestPictures = GalleryData.parseManifest(text());
                root.loadError = "";
            } catch (_) {
                root.manifestPictures = [];
                root.loadError = "Manifesto inválido: revise a lista images.";
            }
        }
        onLoadFailed: {
            if (!root.manifestPath)
                return;
            root.manifestPictures = [];
            root.loadError = "Não foi possível ler o manifesto configurado.";
        }
    }

    HoverHandler { id: galleryHover }

    ClippingRectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surface

        Image {
            anchors.fill: parent
            source: root.current ? GalleryData.fileUrl(root.directory + "/" + root.current.file) : ""
            sourceSize.width: 800
            sourceSize.height: 450
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            scale: galleryHover.hovered && Theme.shortDuration > 0 ? 1.025 : 1
            Behavior on scale {
                NumberAnimation {
                    duration: Math.min(200, Theme.shortDuration)
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: root.currentIndex = (root.currentIndex + 1) % Math.max(1, root.pictures.length)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.fontSizeSmall * 2 + Theme.spacingL
            color: Theme.withAlpha(Theme.surface, 0.94)

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingM
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: collectionButton.left
                anchors.rightMargin: Theme.spacingS
                spacing: Theme.spacingXS / 2

                StyledText {
                    text: root.current ? root.current.collection : "Galeria vazia"
                    width: parent.width
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }
                StyledText {
                    text: root.loadError || (root.current ? (root.current.width && root.current.height ? root.current.width + "×" + root.current.height + " · " : "") + "Clique para avançar" : "Abra a pasta e adicione imagens")
                    textFormat: Text.PlainText
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: Theme.fontSizeSmall * 0.9
                    color: Theme.surfaceVariantText
                }
            }

            DankActionButton {
                id: collectionButton
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingS
                anchors.verticalCenter: parent.verticalCenter
                buttonSize: 30
                iconSize: 18
                iconName: "collections"
                iconColor: Theme.primary
                tooltipText: "Abrir pasta de imagens"
                onClicked: Qt.openUrlExternally(GalleryData.fileUrl(root.directory))
            }
        }
    }
}
