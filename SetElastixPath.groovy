import ch.epfl.biop.wrappers.ij2command.BiopWrappersSet
import ij.IJ

#@CommandService cs
#@String elastixPath
#@String transformixPath

cs.run(BiopWrappersSet.class, true,
	"elastixExecutable", new File(elastixPath),
	"transformixExecutable", new File(transformixPath),
).get()

IJ.run("Quit");
