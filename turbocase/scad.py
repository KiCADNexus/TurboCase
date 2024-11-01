import logging
import math
from jinja2 import Environment, PackageLoader, FileSystemLoader


def _polygon_points(points, label):
    if len(points) == 0:
        log = logging.getLogger('scad')
        log.error(f'Shape "{label}" had no points')
        return []

    if points[0] == 'circle':
        log = logging.getLogger('scad')
        log.error(f'Shape "{label}" is a circle instead of a polygon')
        return []

    result = []
    for p in points:
        result.append([p[0], p[1]])
    return result

def _compile_case_shapes(case):
    for shape in case.pcb_holes:
        if not shape.is_circle:
            if not shape.is_rect:
                shape.points = _polygon_points(shape.path(), "pcb hole")

    for shape in case.cutouts:
        if not shape.is_circle:
            if not shape.is_rect:
                shape.points = _polygon_points(shape.path(), "case cutout")

    for shape in case.lid_holes:
        if not shape.is_circle:
            if not shape.is_rect:
                shape.points = _polygon_points(shape.path(), "lid hole")

    case.connectors = sorted(case.connectors, key=lambda x: x.reference)


def generate(case, show_pcb=False):
    """
    :type case: Case
    """

    # result += '/* [Gridfinity] */\n'
    # result += f'gridx = {math.ceil(case.get_case_size()[0] / 42.0)}; // [1:1:8]\n'
    # result += f'gridy = {math.ceil(case.get_case_size()[1] / 42.0)}; // [1:1:8]\n'
    # result += '\n'

    env = Environment(loader=FileSystemLoader('.'))

    template = env.get_template("turbocase/templates/baseBox.scad")
    # template = env.get_template("turbocase/templates/gridfinityHolder.scad")

    _compile_case_shapes(case)

    result = template.render({
        "show_pcb": show_pcb,
        "case": case,
        "center": case.get_center(),
        "inserts": case.get_inserts(),
        "points_edge_cuts": _polygon_points(case.pcb_path, 'edge.cuts'),
        "points_outline": _polygon_points(case.inner_path, 'case outline'),
        "has_contrained": any(part.constrain for part in case.parts)
    })

    return result
