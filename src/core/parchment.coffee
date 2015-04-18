class Node




class ParchmentNode extends Node
  constructor: ->
    this.children = new LinkedList()

  build: ->

  insertEmbed: (index, name, value) ->
    [child, offset] = children.find(index)
    child.insertEmbed(offset, name, value)

  insertText: (index, text) ->
    [child, offset] = children.find(index)
    child.insertText(offset, text)

  deleteText: (index, length) ->
    this.remove() if index == 0 && length == this.getLength()
    children.forEachAt(index, length, (child, offset, length) =>
      child.deleteText(offset, length)
    )

  formatText: (index, length, name, value) ->
    children.forEachAt(index, length, (child, offset, length) =>
      child.formatText(offset, length, name, value)
    )

  getLength: ->
    return children.reduce((memo, child) ->
      return memo + child.getLength()
    , 0)

  wrap: (name, value) ->
    node = Parchment.create(name, value)
    this.attributes.forEach((attribute) =>
      attribute.add(node)
      attribute.remove(this)
    )
    super

  replace: (name, value) ->
    node = Parchment.create(name, value)
    this.attributes.forEach((attribute) =>
      attribute.add(node)
      attribute.remove(this)
    )
    super


class Parchment extends ParchmentNode
  @Node: ParchmentNode

  @create: (name, value) ->

  @define: (nodeClass) ->




class Block extends ParchmentNode
  formatText: (index, length, name, value) ->
    super
    if index + length > this.getLength()
      this.format(name, value)

  insertText: (index, text) ->
    lineTexts = text.split('\n')
    super(index, lineTexts[0])
    next = this.next
    lineTexts.slice(1).forEach((lineText) =>
      line = Parchment.create('block')
      line.insertText(0, text)
      this.parent.insertBefore(line, next)
    )

  deleteText: (index, length) ->
    if index + length > this.getLength() && this.next?
      this.mergeNext()
    super
    if children.length == 0
      this.append(Parchment.create('break'))

  getLength: ->
    return super() + 1


class Inline
  deleteText: (index, length) ->
    super
    if children.length == 0
      this.append(Parchment.create('break'))

  formatText: (index, length, name, value) ->
    if (order > true)
      this.split(index, length)
      this.wrap(name, value)
    else
      super(index, length, name, value)


class Leaf extends Inline


class Embed extends Leaf
  formatText: (index, length, name, value) ->
    this.wrap(name, value)


class Text extends Leaf
  formatText: (index, length, name, value) ->
    if index != 0 || length != this.getLength()
      this.split(index, length)
    this.wrap(name, value)

  insertText: (index, text) ->
    curText = this.node.textContent
    this.node.textContent = curText.slice(0, index) + text + curText.slice(index)

  insertEmbed: (index, name, value) ->
    this.split(index)
    embed = Parchment.create(name, value)
    this.parent.insertBefore(this.next, embed)


class Break extends Leaf
  formatText: (index, length, name, value) ->
    this.wrap(name, value)

  insertEmbed: (index, name, value) ->
    this.replace(name, value)

  insertText: (index, text) ->
    this.replace('text', text)



Parchment.define()



module.exports = Parchment
