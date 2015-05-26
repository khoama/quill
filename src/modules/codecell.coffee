Quill   = require('../quill')
Tooltip = require('./tooltip')
_       = Quill.require('lodash')
dom     = Quill.require('dom')
Delta   = Quill.require('delta')


class CodeCell extends Tooltip
	@DEFAULTS:
		template: ''

	@events:
		CODE_INSERTED   					: 'code-inserted',
		CURSOR_POSITION_CHANGE		: 'position-change'

	@klasses:
		WRAPPER	:	'code-cell-wrapper'

	constructor: (@quill, @options) ->
		@options = _.defaults(@options, Tooltip.DEFAULTS)
		super(@quill, @options)
		@preview = @container.querySelector('.preview')
		@textbox = @container.querySelector('.input')
		dom(@container).addClass('ql-code-tooltip')
		this.initListeners()

	initListeners: ->
		@quill.onModuleLoad('toolbar', (toolbar) =>
			toolbar.initFormat('code', _.bind(this._onToolbar, this))
		)

	insertCodecell: ->
		id = this._generateUid(@options.document_id, '-')
		@range = new Range(0, 0) unless @range?   # If we lost the selection somehow, just put it at at beginning of document
		quill = @quill
		
		if @range
			index = @range.end

			extra = 
				id:	id
				klass: CodeCell.klasses.WRAPPER

			@quill.insertText(index, "\n\n", {}, "user")
			@quill.insertEmbed(index, 'code', '/codecell/' + id, 'user', extra)
			@quill.insertText(index, "\n\n", {}, "user")

			@quill.emit(CodeCell.events.CODE_INSERTED, id, @quill.modules['code'])
			@quill.emit(CodeCell.events.CURSOR_POSITION_CHANGE, index + 2)

		this.hide()

	_onToolbar: (range, value) ->
		this.show()
		this.insertCodecell()

	_preview: ->
		# return unless this._matchImageURL(@textbox.value)

	_generateUid: (prefix, separator) ->
		S4 = ->
			(((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

		delim = separator or "-"
		_prefix = prefix + delim or ""
		_prefix + S4() + delim + S4() + delim + S4()
		

Quill.registerModule('codecell', CodeCell)
module.exports = CodeCell