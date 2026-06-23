# filter() builds clean CQL without a drop_null artifact (#368)

    Code
      cql(filter(promise, INTERSECTS(bbox)))
    Output
      <SQL> (INTERSECTS(GEOMETRY, POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))))

---

    Code
      cql(filter(filter(promise, INTERSECTS(bbox)), BGC_LABEL != "ZZZ"))
    Output
      <SQL> ((INTERSECTS(GEOMETRY, POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0)))) AND ("BGC_LABEL" != 'ZZZ'))

