#!/usr/bin/env python
"""
    This script is intended for developers to rerun all dask-free notebooks without
    launching JupyterHub or a jupyter lab session.
    It relies on the run_notebooks function.
"""

import os

# Eventually add argparse for this?
# May want even more control over what gets run
submit_notebooks = False
submit_plot_suite_maps = True

if submit_notebooks:
    # For now, plot_suite and trend_maps don't run with nbconvert
    # It may be NCAR_jobqueue related...
    notebooks = []
    notebooks.append("Sanity\ Check.ipynb")
    notebooks.append("Pull\ info\ from\ logs.ipynb")
    notebooks.append(f"compare_ts_and_hist_*.ipynb")
    # notebooks.append(f"plot_suite_maps_*.ipynb")

    cmd = "./run_notebooks.sh " + " ".join(notebooks)
    os.system(cmd)

if submit_plot_suite_maps:
    # Gen plot_suite_maps for 004
    casename = "g.e22.G1850ECO_JRA_HR.TL319_t13.004"
    campaign_root = os.path.join(
        os.sep,
        "glade",
        "campaign",
        "cesm",
        "development",
        "bgcwg",
        "projects",
        "hi-res_JRA",
        "cases",
    )
    for year in range(34):
        cmd = f"./submit_plot_suite_maps.sh {casename} {campaign_root} {year+1:04d}"
        os.system(cmd)
