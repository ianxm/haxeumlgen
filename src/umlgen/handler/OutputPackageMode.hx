package umlgen.handler;

/**
 * Lists all modes which are available
 * for organizing packages
 */
enum OutputPackageMode 
{
	/**
	 * Organize all packages as full qualified packages in a list
	 */
    Flat; 
    /**
     * Organize all packages as hierarchical structure.
     */
    Hierarchical;
}
