# -*- coding: utf-8 -*-

import pytest
from stk.api.mesh import StkMetaData, StkBulkData, StkSelector, StkBucket
from stk.api.topology import rank_t, topology_t

def test_bucket(stk_mesh):
    sel = StkSelector.from_part(stk_mesh.meta.universal_part)
    bkts = stk_mesh.iter_buckets(sel, rank_t.ELEM_RANK)
    bkt = next(bkts)

    assert bkt.topology.value == topology_t.HEX_8
    assert bkt.owned
    assert not bkt.shared
    assert not bkt.in_aura
    assert bkt.size == 1
    assert bkt.entity_rank == rank_t.ELEM_RANK
    assert bkt.bucket_id == 0
