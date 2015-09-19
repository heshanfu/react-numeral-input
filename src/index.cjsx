# @cjsx React.DOM
React = require('react')
numeral = require 'numeral'

re = /[^0-9km,]+/
getCaretPosition = (oField) ->
  iCaretPos = 0
  if document.selection
    oField.focus()
    oSel = document.selection.createRange()
    oSel.moveStart 'character', -oField.value.length
    iCaretPos = oSel.text.length
  else if oField.selectionStart or oField.selectionStart == '0'
    iCaretPos = oField.selectionStart
  iCaretPos

setCaretPosition = (oField, index) ->
  if oField.setSelectionRange
    oField.setSelectionRange(index, index)
  else
    range = oField.createTextRange()
    range.collapse(true)
    range.moveEnd('character', index)
    range.moveStart('character', index)
    range.select()
NumeralInput = React.createClass
  displayName : 'NumeralInput'
  node: null
  propTypes:
    onChange: React.PropTypes.func
    fmt: React.PropTypes.string

  getDefaultProps: ->
    fmt: '0,0'


  # 1,234,567  , 4
  # ->
  # 1234567    , 3
  formatPos: (val, index)->
    #unformat
    val = numeral().unformat(val)
    #format
    val = numeral(val).format(@props.fmt)
    sub = val.substr(0, index-1)
    dotCount  = sub.split(',').length
    pos = index-dotCount
    if pos>0 then pos else 0



  focusOnChar: (val, index)->
    formatVal = numeral(val).format(@props.fmt)
    dotCount=0

    i = 0
    finalIndex = formatVal.length
    while i < formatVal.length
      char = formatVal[i]
      if i is (index + dotCount)
        finalIndex = i
        break
      if char is ','
        dotCount++

      i++

    finalIndex = 1 if not finalIndex
    return finalIndex

  getInitialState: ->
    inputStyle:@props.inputStyle
    placeholder:@props.placeholder
    value: @getNumeralValue(@props.value)

  getNumeralValue: (val)->
    numeral(val).format(@props.fmt)

  componentWillReceiveProps :(nextProps) ->
    if @props.value is nextProps.value
      return
    val = nextProps.value
    pos = @state.pos

    if not re.test(val)
      formatVal = @getNumeralValue(val)
    formatVal = @getNumeralValue(val)

    @setState(
      value: formatVal
    , =>
      node = @getDOMNode()
      setCaretPosition(node, @state.pos)
    )

  changeHandler:()->
    node = @getDOMNode()
    pos = getCaretPosition(node)
    val = node.value
    pos = @formatPos(@state.value, pos)


    ##1,000,000 -> 1000000
    reTest = re.test(val)
    if not reTest
      val = numeral(val).value()
      oVal = numeral(@state.val)
      if ((oVal+'').length < (val+'').length)
        pos = @focusOnChar(val, ++pos)
      else if ((oVal+'').length > (val+'').length)
        pos = @focusOnChar(val, --pos)
      else
        pos = @focusOnChar(val, pos)
    val = numeral(val).value()

    #parentNode onChange function
    @setState(
      pos: pos
      value: val
    , =>
      if @props.onChange
        @props.onChange(val)
    )

  render : ->
    props = @props
    <input type="text" {...props}
      value={@state.value}
      onChange = {@changeHandler}
    />

module.exports = NumeralInput
