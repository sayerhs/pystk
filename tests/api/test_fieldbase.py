# -*- coding: utf-8 -*-

import pytest
import numpy as np
from stk.api.mesh import StkMetaData, StkBulkData, StkSelector
from stk.api.mesh.field import StkFieldBase, FieldState
from stk.api.topology.topology import rank_t

def test_field_properties(stk_mesh_fields):
    mesh = stk_mesh_fields
    meta = mesh.meta
    pressure = meta.get_field("pressure")
    velocity = meta.get_field("velocity")

    assert velocity.name == "velocity"
    assert pressure.name == "pressure"

    assert velocity.meta_data == meta
    assert pressure.meta_data == meta
    assert velocity.bulk_data == mesh.bulk
    assert pressure.bulk_data == mesh.bulk

    assert velocity.number_of_states == 2
    assert pressure.number_of_states == 1
    assert velocity.field_array_rank == 1
    assert pressure.field_array_rank == 0

    assert velocity.is_state_valid(FieldState.StateN) == True
    assert pressure.is_state_valid(FieldState.StateN) == False


def test_field_entity_access(stk_mesh_fields):
    meta = stk_mesh_fields.meta
    bulk = stk_mesh_fields.bulk

    surf = meta.get_part("surface_1")
    sel = StkSelector.from_part(surf)

    pressure = meta.get_field("pressure")
    velocity = meta.get_field("velocity")

    nodes = bulk.iter_entities(sel, rank_t.NODE_RANK)
    node = next(nodes)

    pres = pressure.get(node)
    assert pres.shape == (1,)
    np.testing.assert_allclose(pres[0], 20.0)

    vel = velocity.get(node)
    assert vel.shape == (meta.spatial_dimension,)
    np.testing.assert_allclose(vel, [10.0, 5.0, 0.0])

def test_field_bucket_access(stk_mesh_fields):
    meta = stk_mesh_fields.meta
    bulk = stk_mesh_fields.bulk

    surf = meta.get_part("surface_1")
    sel = StkSelector.from_part(surf)

    pressure = meta.get_field("pressure")
    velocity = meta.get_field("velocity")

    buckets = bulk.iter_buckets(sel, rank_t.NODE_RANK)
    bkt = next(buckets)

    pres = pressure.bkt_view(bkt)
    assert pres.shape == (bkt.size,)
    np.testing.assert_allclose(pres, 20.0)

    vel = velocity.bkt_view(bkt)
    assert vel.shape == (bkt.size, meta.spatial_dimension)
    np.testing.assert_allclose(vel[:, 0], 10.0)
    np.testing.assert_allclose(vel[:, 1], 5.0)
    np.testing.assert_allclose(vel[:, 2], 0.0)

def test_dtype_field_access(hex_1elem_mesh):
    meta = hex_1elem_mesh.meta
    bulk = hex_1elem_mesh.bulk
    iblank = meta.declare_scalar_field_t[int]("iblank")
    iblank.add_to_part(meta.universal_part)
    hex_1elem_mesh.populate_bulk_data()

    surf = meta.get_part("surface_1")
    sel = StkSelector.from_part(surf)

    buckets = bulk.iter_buckets(sel, rank_t.NODE_RANK)
    bkt = next(buckets)

    ibl = iblank.bkt_view_int(bkt)
    assert ibl.dtype == np.int32

def test_field_modification(stk_mesh_fields):
    meta = stk_mesh_fields.meta
    bulk = stk_mesh_fields.bulk

    surf = meta.get_part("surface_1")
    sel = StkSelector.from_part(surf)

    pressure = meta.get_field("pressure")
    velocity = meta.get_field("velocity")

    for bkt in bulk.iter_buckets(sel):
        vel = velocity.bkt_view(bkt)
        pres = pressure.bkt_view(bkt)

        pres[:] = 10.0
        vel[:, 0] = vel[:, 2]
        vel[:, 1] = vel[:, 0]
        vel[:, 2] = vel[:, 1]

    buckets = bulk.iter_buckets(sel, rank_t.NODE_RANK)
    bkt = next(buckets)

    pres = pressure.bkt_view(bkt)
    assert pres.shape == (bkt.size,)
    np.testing.assert_allclose(pres, 10.0)

    vel = velocity.bkt_view(bkt)
    assert vel.shape == (bkt.size, meta.spatial_dimension)
    np.testing.assert_allclose(vel, 0.0)
