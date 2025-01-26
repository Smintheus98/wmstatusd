import macros

macro config*(name: typed, fields: untyped): untyped =
  # config name:
  #   a = 16        ->      name.a = 16
  #   b = false             name.b = true
  var assignments: seq[NimNode]
  for line in fields:
    assignments.add newAssignment(
      newDotExpr(
        name,
        line[0]
      ),
      line[1]
    )
  result = newStmtList(assignments)
