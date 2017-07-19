fs   = require 'fs'
path = require 'path'
{CompositeDisposable} = require 'atom'

root = document.documentElement

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
    path.join __dirname, "..", "styles", "config-variables.less"

  getConfigVariablesContent: () ->
    """
    @cfg-bg: #{@cfg_backgroundColor};
    """

  refreshTheme: () ->
    console.log("REFRESH")
    fs.writeFileSync @getConfigVariablesPath(), @getConfigVariablesContent()

  activate: (state) ->
    @packageName = require('../package.json').name

    atom.config.observe 'luna-dark-ui.fontSize', (value) ->
      setFontSize(value)

    atom.config.observe 'luna-dark-ui.tabSizing', (value) ->
      setTabSizing(value)

    atom.config.observe 'luna-dark-ui.hideDockButtons', (value) ->
      setHideDockButtons(value)

    foo = this
    atom.config.observe 'luna-dark-ui.backgroundColor', (value) ->
      rgbPattern  = ///^(\#[0-9a-fA-F]{6})$///
      lessPattern = ///^`(.*)`///
      match  = (value.match rgbPattern) || (value.match lessPattern)
      newVal = match?[1] || ("\"#{value}\"" if value == "auto")
      if newVal
        foo.cfg_backgroundColor = newVal
        foo.refreshTheme()
      else console.debug "Text '#{value}' is not a valid config value."

    # DEPRECATED: This can be removed at some point (added in Atom 1.17/1.18ish)
    # It removes `layoutMode`
    if atom.config.get('luna-dark-ui.layoutMode')
      atom.config.unset('luna-dark-ui.layoutMode')









    markOpen = (textEditor) =>
      filePath = textEditor.getPath()
      entry = @treeView.entryForPath filePath
      if entry
        entry.classList.add 'open'
      else
        console.debug "Resonance-UI: Add: Not found entry for ", filePath

    treeListAddOpen = (event) =>
      console.debug "Resonance-UI: treeListAddOpen"
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
    unsetFontSize()
    unsetTabSizing()
    unsetHideDockButtons()
    @disposables.dispose()

  config:
    fontSize:
      type:    ['integer', 'string']
      minimum: 8
      maximum: 20
      default: 'Auto'
      order:   1
    tabSizing:
      type:    'string'
      default: 'Even'
      enum:    ['Even', 'Maxinmum', 'Minimum']
      order:   2
    hideDockButtons:
      type:    'boolean'
      default: 'false'
      order:   3
    someSetting:
      type: 'array'
      default: [1, 2, 3]
      items:
        type: 'integer'
        minimum: 1.5
        maximum: 11.5
      order:   4
    backgroundColor:
      type: 'string'
      default: 'auto'
      order:   5


# Font Size -----------------------

setFontSize = (currentFontSize) ->
  if Number.isInteger(currentFontSize)
    root.style.fontSize = "#{currentFontSize}px"
  else if currentFontSize is 'Auto'
    unsetFontSize()

unsetFontSize = ->
  root.style.fontSize = ''


# Tab Sizing -----------------------

setTabSizing = (tabSizing) ->
  root.setAttribute('theme-one-dark-ui-tabsizing', tabSizing.toLowerCase())

unsetTabSizing = ->
  root.removeAttribute('theme-one-dark-ui-tabsizing')


# Dock Buttons -----------------------

setHideDockButtons = (hideDockButtons) ->
  if hideDockButtons
    root.setAttribute('theme-one-dark-ui-dock-buttons', 'hidden')
  else
    unsetHideDockButtons()



unsetHideDockButtons = ->
  root.removeAttribute('theme-one-dark-ui-dock-buttons')
