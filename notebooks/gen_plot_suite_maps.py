#!/usr/bin/env python

import utils


def _parse_args():
    """ Parse command line arguments
    """

    import argparse

    parser = argparse.ArgumentParser(
        description="Generate all plot suite maps for a given case, stream, and year",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # Command line argument to point to JSON file (default is $MARBLROOT/defaults/json/settings_latest.json)
    parser.add_argument(
        "-c",
        "--casename",
        action="store",
        dest="casename",
        required=True,
        help="Name of case providing data for plotting",
    )

    # Is the GCM providing initial bury coefficients via saved state?
    parser.add_argument(
        "-d",
        "--in-dir",
        action="store",
        dest="in_dir",
        required=True,
        help="Location of output files (can be rundir, archive, or location of time series)",
    )

    # Command line argument to specify resolution (default is None)
    parser.add_argument(
        "-s",
        "--stream",
        action="store",
        dest="stream",
        default="pop.h",
        help="Stream containing diagnostics to plot",
    )

    # Command line argument to specify a settings file which would override the JSON
    parser.add_argument(
        "-y", "--year", action="store", dest="year", default=1, help="Year to plot"
    )

    # Command line argument to where to write the settings file being generated
    parser.add_argument(
        "-m",
        "--metadata-file",
        action="store",
        dest="metadata_file",
        default="diag_metadata.yaml",
        help="YAML file containing information about which fields to plot",
    )

    return parser.parse_args()


if __name__ == "__main__":
    args = _parse_args()
    utils.plot_suite_maps(
        args.casename, args.in_dir, args.stream, args.year, args.metadata_file
    )
