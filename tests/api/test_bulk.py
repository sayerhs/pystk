# -*- coding: utf-8 -*-

import pytest
from stk.api.mesh import StkMetaData, StkBulkData, StkSelector
from stk.api.topology import rank_t

def test_bulk_create(parallel):
    meta = StkMetaData.create()
    bulk = StkBulkData.create(meta, parallel)
    assert bulk.parallel_size == parallel.size
    assert bulk.parallel_rank == parallel.rank

def test_bulk_entity_relations(hex_1elem_mesh):
    mesh = hex_1elem_mesh
    mesh.populate_bulk_data(create_edges = True)
    bulk = mesh.bulk
    sel = StkSelector.from_part(mesh.meta.universal_part)

    elems = mesh.iter_entities(sel, rank_t.ELEM_RANK)
    el = next(elems)
    assert bulk.num_nodes(el) == 8
    assert bulk.num_faces(el) == 6
    assert bulk.num_edges(el) == 12
    assert bulk.parallel_owner_rank(el) == 0

    nodes = mesh.iter_entities(sel, rank_t.NODE_RANK)
    node = next(nodes)
    assert bulk.num_elements(node) == 1
    assert bulk.num_faces(node) == 3
    assert bulk.num_edges(node) == 3
    assert bulk.parallel_owner_rank(node) == 0

    faces = mesh.iter_entities(sel, rank_t.FACE_RANK)
    face = next(faces)
    assert bulk.num_elements(face) == 1
    assert bulk.num_nodes(face) == 4
    assert bulk.num_edges(face) == 4
    assert bulk.parallel_owner_rank(face) == 0

    edges = mesh.iter_entities(sel, rank_t.EDGE_RANK)
    edge = next(edges)
    assert bulk.num_elements(edge) == 1
    assert bulk.num_nodes(edge) == 2
    assert bulk.num_faces(edge) == 2
    assert bulk.parallel_owner_rank(edge) == 0

def test_bulk_identifier(hex_1elem_mesh):
    mesh = hex_1elem_mesh
    mesh.populate_bulk_data(create_edges = True)
    bulk = mesh.bulk
    sel = StkSelector.from_part(mesh.meta.universal_part)

    elems = mesh.iter_entities(sel, rank_t.ELEM_RANK)
    el = next(elems)
    assert bulk.identifier(el) == 1

    min_node_id = 10000
    max_node_id = 0
    for node in mesh.iter_entities(sel, rank_t.NODE_RANK):
        node_id = bulk.identifier(node)
        min_node_id = min(min_node_id, node_id)
        max_node_id = max(max_node_id, node_id)

    assert min_node_id == 1
    assert max_node_id == 8
