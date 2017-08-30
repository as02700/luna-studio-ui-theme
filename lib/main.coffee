fs   = require 'fs'
path = require 'path'
{CompositeDisposable} = require 'atom'
# root = document.documentElement

`
function componentToHex(c) {
    var hex = c.toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b) {
    return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
}
`
    # @cfg-baseColor: #{rgbToHex(@baseColor.red, @baseColor.green, @baseColor.blue)};

module.exports =
  getConfigVariablesPath: ->
    basePath = path.join __dirname, '..', 'styles', 'generated'
    if not fs.existsSync basePath
      fs.mkdir basePath
    path.join basePath, "globals.less"

  getConfigVariablesContent: () ->
    """
    @cfg-bg: #{@cfg_backgroundColor};
    """

  refreshTheme: () ->
    fs.writeFileSync @getConfigVariablesPath(), @getConfigVariablesContent()

  activate: (state) ->
    @packageName = require('../package.json').name


    foo = this
    atom.config.observe (@packageName + '.backgroundColor'), (value) ->
      v = value
      if value == 'auto'
        v = "\"#{value}\""

      rgbPattern  = ///^(\#[0-9a-fA-F]{6})$///
      lessPattern = ///^`(.*)`///
      match  = (value.match rgbPattern) || (value.match lessPattern)
      newVal = match?[1] || ("\"#{value}\"" if value == "auto")
      if newVal
        foo.cfg_backgroundColor = newVal
        foo.refreshTheme()
      else console.debug "Text '#{value}' is not a valid config value."










    markOpen = (textEditor) =>
      filePath = textEditor.getPath()
      entry = @treeView.entryForPath filePath
      if entry
        entry.classList.add 'open'
      else
        console.debug "Luna-UI: Add: Not found entry for ", filePath

    treeListAddOpen = (event) =>
      console.debug "Luna-UI: treeListAddOpen"
      console.log (event)
      if @treeView
        markOpen event.textEditor

    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.onDidAddTextEditor treeListAddOpen

    atom.packages.activatePackage('tree-view').then (treeViewPkg) =>
      if not @treeView
        @treeView = treeViewPkg.mainModule.treeView
        markOpened = (entry) => if not (entry.classList.contains '.opened')
            entry.classList.add 'opened'
            if entry.nodeName == "LI"
              markOpened entry.parentElement.parentElement
        refreshAll = =>
          for entry in @treeView.list.querySelectorAll('.opened')
            entry?.classList.remove 'opened'
          for editor in atom.workspace.getTextEditors()
            fpath = editor.buffer.file?.path
            entry = @treeView.entryForPath(fpath) if fpath?
            markOpened entry if entry?
        @treeView.onDirectoryCreated refreshAll
        @treeView.onEntryCopied      refreshAll
        @treeView.onEntryDeleted     refreshAll
        @treeView.onEntryMoved       refreshAll
        @treeView.onFileCreated      refreshAll
        oldEntryClicked = @treeView.entryClicked
        @treeView.entryClicked = (e) =>
          oldEntryClicked.call(@treeView, e)
          refreshAll()
        atom.workspace.observeTextEditors   refreshAll
        atom.workspace.onDidDestroyPaneItem refreshAll
        refreshAll()
      else
        console.debug "TreeView Dim: Tree-view already activated"

    # @refreshTheme()
    # Options.apply()

  deactivate: ->
    @disposables.dispose()

  config:
    backgroundColor:
      order   : 1
      description: 'WARNING: Changing this option could take several seconds, depending on how powerful the machine you are currently running is. It is an exported variable and could be used by any other package, so all already loaded styles have to be reloaded.'
      type    : 'string'
      default : 'inherit'
      enum    : [
        {value: 'inherit', description: 'Inherit from syntax theme'}
        {value: 'custom' , description: 'Custom'}
      ]
    customBackgroundColor:
      order   : 2
      type    : 'color'
      default : 'black'
    contrast:
      description: 'Contrast of all theme elements. Increasing this value would make theme more readable but will also make your eyes hurt more.'
      order   : 3
      type    : 'string'
      default : 'auto'
      enum    : [
        {value: 'auto', description: 'Automatic, depending on the theme\'s lightness'}
        {value: '8' , description: 'Very Slight'}
        {value: '8' , description: 'Slight'}
        {value: '8' , description: 'Medium'}
        {value: '8' , description: 'Medium'}
        {value: '8' , description: 'Strong'}
        {value: '8' , description: 'Very Strong'}
        {value: '8' , description: 'Custom'}
      ]
    customContrast:
      order   : 4
      type    : 'number'
      default : 1.0


# Font Size -----------------------
#
# setFontSize = (currentFontSize) ->
#   if Number.isInteger(currentFontSize)
#     root.style.fontSize = "#{currentFontSize}px"
#   else if currentFontSize is 'Auto'
#     unsetFontSize()
#
# unsetFontSize = ->
#   root.style.fontSize = ''
#
#
# # Tab Sizing -----------------------
#
# setTabSizing = (tabSizing) ->
#   root.setAttribute('theme-one-dark-ui-tabsizing', tabSizing.toLowerCase())
#
# unsetTabSizing = ->
#   root.removeAttribute('theme-one-dark-ui-tabsizing')
#
#
# # Dock Buttons -----------------------
#
# setHideDockButtons = (hideDockButtons) ->
#   if hideDockButtons
#     root.setAttribute('theme-one-dark-ui-dock-buttons', 'hidden')
#   else
#     unsetHideDockButtons()
#
#
#
# unsetHideDockButtons = ->
#   root.removeAttribute('theme-one-dark-ui-dock-buttons')
