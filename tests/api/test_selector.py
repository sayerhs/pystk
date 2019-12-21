# -*- coding: utf-8 -*-

import pytest
from stk.api.mesh import StkMetaData, StkBulkData, StkSelector
from stk.api.topology import rank_t

def test_sel_from_part(stk_mesh):
    part = stk_mesh.meta.get_part("surface_1")
    assert not part.is_null
    sel = StkSelector.from_part(part)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert sel.is_empty(rank_t.ELEM_RANK)

def test_sel_from_field_existing(stk_mesh_fields):
    """Tests where the field exists and normal behavior"""
    vel = stk_mesh_fields.meta.get_field("velocity")
    sel = StkSelector.select_field(vel)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert not sel.is_empty(rank_t.ELEM_RANK)

def test_sel_from_field(hex_1elem_mesh):
    mesh = hex_1elem_mesh
    vel = mesh.meta.declare_vector_field("velocity")
    # Don't register the field to ensure that the selection turns up empty
    mesh.populate_bulk_data(create_edges=True)
    sel = StkSelector.select_field(vel)
    assert sel.is_empty(rank_t.FACE_RANK)
    assert sel.is_empty(rank_t.NODE_RANK)
    assert sel.is_empty(rank_t.EDGE_RANK)
    assert sel.is_empty(rank_t.ELEM_RANK)

    # But selector on coordinates is not empty
    coords = mesh.meta.coordinate_field
    sel = StkSelector.select_field(coords)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert not sel.is_empty(rank_t.ELEM_RANK)

def test_sel_intersection(stk_mesh_fields):
    mesh = stk_mesh_fields
    sel = StkSelector.and_(
        mesh.meta.get_part("surface_1"),
        mesh.meta.locally_owned_part)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert sel.is_empty(rank_t.ELEM_RANK)

    sel = StkSelector.and_(
        mesh.meta.get_part("block_1"),
        mesh.meta.locally_owned_part)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert not sel.is_empty(rank_t.ELEM_RANK)

    sel = StkSelector.and_(
        mesh.meta.get_part("surface_1"),
        mesh.meta.globally_shared_part)
    assert sel.is_empty(rank_t.FACE_RANK)
    assert sel.is_empty(rank_t.NODE_RANK)
    assert sel.is_empty(rank_t.EDGE_RANK)
    assert sel.is_empty(rank_t.ELEM_RANK)

    sel = StkSelector.and_(
        mesh.meta.get_part("block_1"),
        mesh.meta.globally_shared_part)
    assert sel.is_empty(rank_t.FACE_RANK)
    assert sel.is_empty(rank_t.NODE_RANK)
    assert sel.is_empty(rank_t.EDGE_RANK)
    assert sel.is_empty(rank_t.ELEM_RANK)

def test_sel_union(stk_mesh_fields):
    mesh = stk_mesh_fields
    sel = StkSelector.or_(
        mesh.meta.get_part("surface_1"),
        mesh.meta.locally_owned_part)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert not sel.is_empty(rank_t.ELEM_RANK)

    sel = StkSelector.or_(
        mesh.meta.get_part("surface_1"),
        mesh.meta.globally_shared_part)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert sel.is_empty(rank_t.ELEM_RANK)

    sel = StkSelector.or_(
        mesh.meta.get_part("block_1"),
        mesh.meta.globally_shared_part)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert not sel.is_empty(rank_t.ELEM_RANK)

def test_sel_part_union(stk_mesh):
    parts = [stk_mesh.meta.get_part("surface_%d"%(i+1))
             for i in range(6)]
    sel = StkSelector.select_union(parts)
    assert not sel.is_empty(rank_t.FACE_RANK)
    assert not sel.is_empty(rank_t.NODE_RANK)
    assert not sel.is_empty(rank_t.EDGE_RANK)
    assert sel.is_empty(rank_t.ELEM_RANK)

def test_sel_complement(stk_mesh):
    parts = [stk_mesh.meta.get_part("surface_%d"%(i+1))
             for i in range(6)]
    sel = StkSelector.select_union(parts).complement()
    assert sel.is_empty(rank_t.FACE_RANK)
    assert sel.is_empty(rank_t.NODE_RANK)
    assert sel.is_empty(rank_t.EDGE_RANK)
    assert not sel.is_empty(rank_t.ELEM_RANK)
