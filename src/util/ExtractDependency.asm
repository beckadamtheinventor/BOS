;@DOES Extract a function dependency from a file by name.
;@INPUT bool util_ExtractDependency(void *fd, const char *name, void **location);
;@OUTPUT true if function is found, *location = address function was extracted to.
util_ExtractDependency:
	ret
