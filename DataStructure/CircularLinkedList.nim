type
  CircularLinkedList*[T] = object
    last: ref Node[T]
  Node*[T] = object
    data*: T
    next*: ref Node[T]

proc newNode*[T](data: T): ref Node[T] = 
  new(result)
  result.data = data
  result.next = nil
proc newCircularLinkedList*[T](): CircularLinkedList[T] = 
  result.last = nil

iterator items*[T](this: CircularLinkedList[T]): T =
  if this.last != nil:
    let head = this.last.next
    yield head.data
    var tmp = head.next
    while tmp != head:
      yield tmp.data
      tmp = tmp.next
proc print*[T](this: CircularLinkedList[T]) = 
  for i in this.items():
    stdout.write($i & " ")
  stdout.write("\n")
proc getTail*[T](this: CircularLinkedList[T]): ref Node[T] =
  return this.last

proc pushFront*[T](this: var CircularLinkedList[T], data: T): ref Node[T] {.discardable} =
  result = newNode(data)
  if this.last != nil:
    result.next = this.last.next
    this.last.next = result
  else:
    result.next = result
    this.last = result
  return result
proc insertAfter*[T](this: var CircularLinkedList[T], pos: ref Node[T], data: T): ref Node[T] {.discardable} =
  result = newNode(data)
  if this.last != nil:
    result.next = pos.next
    pos.next = result
  else:
    result.next = result
    this.last = result
  return result
proc pushBack*[T](this: var CircularLinkedList[T], data: T): ref Node[T] {.discardable} =
  let tail = this.getTail()
  let n: ref Node[T] = insertAfter(this, tail, data)
  return n

proc delNode*[T](this: var CircularLinkedList[T], key: T) =
  if this.last == nil:
    raise newException(OSError, "Try to delete node in empty Linked  List")

  let head = this.last.next
  if head.data != key:
    var tmp = head.next
    var pre = head
    while tmp != head and tmp.data != key:
      pre = tmp
      tmp = tmp.next
    if tmp != head:
      let new_next = tmp.next
      tmp.next = nil
      pre.next = new_next
  else:
    this.last.next = head.next
proc delAt*[T](this: var CircularLinkedList[T], pos: int) =
  assert pos >= 0
  if this.last == nil:
    raise newException(OSError, "Try to delete node in empty Linked  List")

  let head = this.last.next
  if head == this.last and pos == 0:
    this.last = nil
  elif head == this.last and pos > 0:
    raise newException(OSError, "Try to delete a node out range of Linked  List")
  else:
    # 最起码有 2 个节点
    var tmp = head.next
    var pre = head
    var cnt = 1
    while tmp.next != head and cnt != pos:
      inc cnt
      pre = tmp
      tmp = tmp.next
    if tmp.next == head and cnt != pos:
      raise newException(OSError, "Try to delete a node out range of Linked  List")
    else:
      let new_next = tmp.next
      tmp.next = nil
      pre.next = new_next

proc len*[T](this: CircularLinkedList[T]): int =
  if this.last == nil:
    return 0
  else:
    let head = this.last.next
    var tmp = head
    result = 1
    while tmp != this.last:
      tmp = tmp.next
      inc result
    return result
    
########## Todo ##############
#[
proc swapNode*[T](this: var CircularLinkedList[T], x, y: T) =
  if x == y:
    return

  var tmpx = this.head
  var tmpy = this.head

  # Todo: 将两个遍历循环优化为一个
  var preX: ref Node[T] = nil
  while tmpx != nil and tmpx.data != x:
    preX = tmpx
    tmpx = tmpx.next
  
  var preY: ref Node[T] = nil
  while tmpy != nil and tmpy.data != y:
    preY = tmpy
    tmpy = tmpy.next
  
  if tmpx == nil or tmpy == nil:
    raise newException(OSError, "can not find these value in CircularLinkedList")
  
  # 先处理 pre.next 这个指针，分为 头节点 和 非头节点 2 中情况处理
  if preX == nil:
    this.head = tmpy
  else:
    preX.next = tmpy
  if preY == nil:
    this.head = tmpx
  else:
    preY.next = tmpx
  
  # 再 交换 curr.next 指针的值
  let tmp_ref = tmpx.next
  tmpx.next = tmpy.next
  tmpy.next = tmp_ref

proc reverseIte*[T](this: var CircularLinkedList[T]) = 
  var pre: ref Node[T] = nil
  var curr = this.head
  var tmp_next: ref Node[T]
  while curr != nil:
    # 必须临时保存正向的下一个，因为等会改动了 curr.next
    tmp_next = curr.next
    # 反转指向
    curr.next = pre
    # 往前推进一个
    pre = curr
    curr = tmp_next
  # 更新 head
  this.head = pre

proc reverseRecUtil[T](curr, pre: ref Node[T], head: var ref Node[T]) =
  var curr = curr
  if curr.next == nil:
    curr.next = pre
    head = curr
  else:
    let tmp_next = curr.next
    curr.next = pre
    reverseRecUtil(tmp_next, curr, head)
proc reverseRec*[T](this: var CircularLinkedList[T]) =
  if this != nil:
    reverseRecUtil(this, nil, this)

proc reverseIte*[T](this: var CircularLinkedList[T], cnt: int) =
  ## 只反转链表中前 cnt 个元素
  let head = this.head
  var pre: ref Node[T] = nil
  var cur = this.head
  var tmp_next: ref Node[T]
  var count = 0
  while count != cnt and cur != nil:
    tmp_next = cur.next
    cur.next = pre
    pre = cur
    cur = tmp_next
    inc count
  if count != cnt:
    raise newException(OSError, "no enough elements in CircularLinkedList to reverse")
  head.next = cur
  this.head = pre

proc detectLoopAndRemove*[T](this: var CircularLinkedList[T]): bool {.discardable} =
  var slow = this.head
  var fast = this.head

  # 必然在环中相遇
  while slow != nil and fast != nil and fast.next != nil:
    slow = slow.next
    fast = fast.next.next
    if slow == fast:
      break

  if slow != fast:
    return false
    
  # 数一下环中有多少个元素
  fast = fast.next
  var loop_count = 1
  while fast != slow:
    fast = fast.next
    inc loop_count

  slow = this.head
  fast = this.head
  # fast 先在 loop_count 步
  for i in 0..<loop_count:
    fast = fast.next
  
  # 必然再环的起始位置相遇
  while slow != fast:
    slow = slow.next
    fast = fast.next
  # 找到环的末尾
  while fast.next != slow:
    fast = fast.next
  fast.next = nil
  return true

proc detectLoopAndRemove1*[T](this: var CircularLinkedList[T]): bool {.discardable} =
  var slow = this
  var fast = this.next # 注意开始 fast 就比 slow 快 1 步
  # lower 走 1 步，fast 走 2 步，必然在环中相遇
  while fast != nil and fast.next != nil:
    slow = slow.next
    fast = fast.next.next
    if slow == fast:
      break

  if slow != fast:
    return false

  slow = this
  while slow != fast.next:
    # 必然 slow 在环的开始， fast 在环的末尾
    slow = slow.next
    fast = fast.next
  fast.next = nil
  return true

proc rotate*[T](this: var CircularLinkedList[T], count: int) =
  if count == 0 or this.head == nil:
    return

  var cnt = 0 
  var pre: ref Node[T]
  let old_head = this.head
  var cur = this.head
  while cur != nil and cnt != count:
    pre = cur
    cur = cur.next
    inc cnt
  if cnt != count:
    raise newException(OSError, "no enough elements to ratate")
  if cur == nil:
    return

  pre.next = nil
  this.head = cur
  var tmp = cur
  while tmp.next != nil:
    tmp = tmp.next
  tmp.next = old_head
  
]#
when isMainModule:
  var ll = newCircularLinkedList[int]()
  ll.pushFront(1)
  ll.pushFront(2)
  ll.pushBack(3)
  ll.pushBack(4)
  ll.print()
  ll.insertAfter(ll.last.next.next, 10)
  ll.print()
  ll.insertAfter(ll.getTail(), 5)
  ll.print()
  ll.delNode(1)
  echo ll.last.data
  ll.print()
  #ll.delAt(0)
  #ll.delAt(1)
  #ll.print()
  #[
  ll.swapNode(2, 5)
  ll.print()
  ll.reverseIte()
  #ll.reverseRec()
  ll.print()
  ll.pushFront(4)
  ll.pushFront(3)
  ll.pushFront(2)
  ll.pushFront(1)
  ll.getTail().next = ll.head.next.next
  ll.detectLoopAndRemove()
  ll.print()
  ll.rotate(0)
  ll.print()
  ]#

  
  