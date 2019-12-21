# -*- coding: utf-8 -*-

import pytest
from stk.api.mesh.meta import StkMetaData
from stk.api.topology.topology import rank_t, topology_t

@pytest.mark.parametrize("ndim", [1, 2, 3])
def test_meta_create(ndim):
    meta = StkMetaData.create(ndim=ndim)
    assert (meta is not None)
    assert (meta.spatial_dimension == ndim)

    assert (meta.is_initialized)
    assert not meta.is_committed

    side_ranks = {
        1: rank_t.NODE_RANK,
        2: rank_t.EDGE_RANK,
        3: rank_t.FACE_RANK
    }
    assert meta.side_rank == side_ranks[ndim]

def test_meta_default_parts():
    meta = StkMetaData.create()
    assert (meta.universal_part)
    assert (meta.locally_owned_part)
    assert (meta.globally_shared_part)

    assert (meta.universal_part.name == "{UNIVERSAL}")
    assert (meta.locally_owned_part.name == "{OWNS}")

def test_meta_declare_part():
    meta = StkMetaData.create()
    block1 = meta.declare_part("block_1", rank_t.ELEM_RANK)
    assert(block1.name == "block_1")
    assert(not block1.is_null)

    surf1 = meta.declare_part("surface_1", rank_t.FACE_RANK)
    assert (surf1.name == "surface_1")
    assert (not surf1.is_null)

def test_meta_get_part(stk_mesh):
    meta = stk_mesh.meta
    block1 = meta.get_part("block_1")

    assert block1.topology.value == topology_t.HEX_8

    for i in range(1, 7):
        surfname = "surface_%d"%i
        surf = meta.get_part(surfname)
        assert surf.name == surfname
        for subpart in surf.subsets:
            assert subpart.topology.value == topology_t.QUAD_4

    surf = meta.get_part("terrain")
    assert surf.is_null
    with pytest.raises(AssertionError):
        surf = meta.get_part("terrain", must_exist=True)

def test_meta_get_parts(stk_mesh):
    parts = stk_mesh.meta.get_parts()
    # Base parts (elements and sidesets) + quad_4 subset for surfaces
    assert len(parts) == 13
