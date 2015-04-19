class TreeNode
  constructor: ->
    @prev = @next = @parent = null
    @children = null

  length: ->
    return 1

  append: (node) ->
    this.insertBefore(node, null)

  insertBefore: (node, refNode) ->
    @children = new LinkedList() unless @children?
    @children.insertBefore(node, refNode)
    node.parent = this

  remove: ->
    return unless @parent?.children?
    @parent.children.remove(this)
    @parent = @prev = @next = null

  replace: (node) ->
    return unless @parent?.children?
    @parent.children.insertBefore(node, this)
    this.remove()

  wrap: (node) ->
    this.replace(node)
    node.append(this)   # node should have no children
    @parent = node


class LinkedList
  constructor: ->
    @head = @tail = null
    @length = 0

  append: (node) ->
    this.insertBefore(node, null)

  insertBefore: (node, refNode) ->
    node.next = refNode
    if refNode?
      node.prev = refNode.prev
      refNode.prev.next = node if refNode.prev?
      refNode.prev = node
      node = @head if refNode == @head
    else if @tail?
      @tail.next = node
      @tail = node
    else
      @head = @tail = node
    @length += 1

  remove: (node) ->
    node.prev.next = node.next if node.prev?
    node.next.prev = node.prev if node.next?
    @head = node.next if node == @head
    @tail = node.prev if node == @tail
    node.prev = node.next = null
    @length -= 1

  forEach: (callback) ->
    cur = @head
    while cur?
      next = cur.next
      callback(cur)
      cur = next

  forEachAt: (index, length, callback) ->
    curNode = @head
    curIndex = 0
    while cur? && curIndex <= index + length
      next = cur.next
      curLength = cur.length()
      if curIndex <= index && index <= curIndex + curLength
        callback(cur, index - curIndex, curLength)
      cur = next
      curIndex += curLength

  reduce: (callback, memo) ->
    cur = @head
    while cur?
      next = cur.next
      memo = callback(memo, cur)
      cur = next


class ParchmentNode extends TreeNode
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

  replace: (name, value) ->
    node = Parchment.create(name, value)
    this.attributes.forEach((attribute) =>
      attribute.add(node)
      attribute.remove(this)
    )
    super

  split: (index) ->
    clone = this.clone()
    this.parent.insertBefore(clone, this)
    this.children.forEachAt(0, index, (child, offset, length) ->
      child.remove()
      clone.append(child)
    )

  wrap: (name, value) ->
    node = Parchment.create(name, value)
    this.attributes.forEach((attribute) =>
      attribute.add(node)
      attribute.remove(this)
    )
    super


class Parchment extends ParchmentNode
  @Node: ParchmentNode

  @create: (name, value) ->
    # Create both ParchmentNode and parallel DOM node

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
