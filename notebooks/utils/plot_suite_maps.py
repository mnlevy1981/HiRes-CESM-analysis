"""
Replacing the guts of the plot_suite_maps notebooks with a module
so that jobs can be distributed across Casper to generate these
plots in parallel
"""

import yaml

from .CaseClass import CaseClass
from .Plotting import summary_plot_maps


def _summary_plots(ds, diag_metadata, save_pngs=False):
    varname = diag_metadata["varname"]
    print(varname)
    da = ds[varname].isel(diag_metadata.get("isel_dict"))

    summary_plot_maps(
        ds,
        da,
        diag_metadata,
        save_pngs=save_pngs,
        savefig_kwargs={"dpi": 72},  # match default behavior of savefig
    )


def plot_suite_maps(casename, in_dir, stream, year, metadata_file="diag_metadata.yaml"):
    # Set up CaseClass object
    case = CaseClass(casename, f"{in_dir}")

    # Get diagnostic metadata
    with open(metadata_file, mode="r") as fptr:
        diag_metadata_list = yaml.safe_load(fptr)

    for diag_metadata in diag_metadata_list:
        print(f"Looking for {diag_metadata['varname']} in {stream}")
        ds = case.gen_dataset(
            diag_metadata["varname"], stream, start_year=int(year), end_year=int(year)
        )
        _summary_plots(ds, diag_metadata, save_pngs=True)
