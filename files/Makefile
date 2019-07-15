###############################################################################
#                                                                             #
#       Machine dependent Makefile header for CNSsolve                        #
#       Paul Adams  20-10-98                                                  #
#       copyright Yale University                                             #
#                                                                             #
###############################################################################

# fortran options
F77 = gfortran
F77STD = -fdefault-integer-8 -w
F77OPT = -O3 $(CNS_MALIGN_I86) -funroll-loops
F77FLAGS = $(F77STD) $(F77OPT) $(EXT_F77FLAGS) $(F77BUG)

# C options
CC = gcc
CPP = g++
CCFLAGS = -O -DINTEGER='long int' -DCNS_ARCH_TYPE_$(CNS_ARCH_TYPE) $(EXT_CCFLAGS)

# link options
LD = gfortran
LDFLAGS = -w $(EXT_LDFLAGS)

# utility programs
compile-utils:
	@ cd $(CNS_INST)/utils; \
	  make utils F77="$(F77)"  CC="$(CC)" CPP="$(CPP)"\
	             F77FLAGS="-w -O" CCFLAGS="-O" \
	             F77LINK="" CCLINK="-lm" LEXLIB="fl"

#==============================================================================
    
# Makefile - autobuild Mon 10 Jun 11:21:28 BST 2019
    
OBJS = angledb.o aria.o ariass.o arical.o ariman.o arivio.o array.o carb.o cluster.o cns.o connect.o coorio.o corman.o coup.o cstack.o cstran.o dcartesian.o define.o diff_anis.o distan.o dsearch.o dtorsion_md.o dtorsion_top.o dynio.o eangle.o ebond.o enbond.o energy.o etor.o expression.o fastnb.o fft.o fftvfy.o flagmap.o genic.o heap.o heapvfy.o hybrid_36_f.o imf.o initia.o lbfgs.o lidens.o machine_f.o machvar.o mapyard.o matrix.o mindist.o mmdisg.o modes.o mrigid.o mtfio.o nbonds.o ncs.o noe.o onebond.o parmio.o parser.o pick.o pig.o plane.o powell.o print.o prot.o psearch.o psfio.o rama.o read_write.o rotate.o rotlsq.o rotman.o rsearch.o rtfio.o segmnt.o selrpn.o smf.o sort.o string.o surfac.o susc_anis.o test.o tsmapd.o tsmapdlm.o tsmap.o tsmaplm.o tsmaps.o update.o util.o vectangl.o vector.o vector_func.o vfynum.o xasymm.o xdeclare.o xdo.o xdofft.o xdofried.o xfalgebra.o xfft.o xfunct.o xmalgebra.o xmask.o xmaskio.o xmaverage.o xmaxl.o xmphisto.o xmpsele.o xmread.o xmulti.o xmwrite.o xparse.o xpeakpik.o xpred.o xprobab.o xprox.o xray.o xreduce.o xreflstar.o xremap.o xrmani.o xropti.o xscale.o xsdev.o xsfsele.o xshow.o xsigmaa.o xskel.o xspecial.o xstats.o xsymm.o xtarget.o xutil.o xyzparse.o
    
###############################################################################
#                                                                             #
#       Source directory proto Makefile for CNSsolve                          #
#       Paul Adams 20-10-98                                                   #
#       copyright Yale University                                             #
#                                                                             #
###############################################################################

.SUFFIXES:
.SUFFIXES: .o

SHELL=/bin/sh

# commands
RM = /bin/rm

# dependencies
DEPENDS = $(OBJS) dmemory.o machine_c.o

# the default is to make the cns executable
cns_solve:
	@ make -k printflags       F77BUG="$(debug)" DEBUG="$(debug)"
	@ make -k ../bin/cns_solve F77BUG="$(debug)" DEBUG="$(debug)"
	@ make -k exepurge

# rule for the fortran routines
$(OBJS): 
	@ echo "compiling: $(@:.o=.f)"; \
	  $(F77) -c $(F77FLAGS) $(@:.o=.f)

# rule for the dynamic memory allocation C routines
dmemory.o: dmemory.c
	@ echo ; echo "compiling: $?"
	@ $(CC) -c $(CCFLAGS) $?

# rule for the machine specific C routines
machine_c.o: machine_c.c
	@ echo ; echo "compiling: $?"
	@ $(CC) -c $(CCFLAGS) $?

# rule for the executable itself
../bin/cns_solve: $(DEPENDS) 
	@ echo ; echo "linking: cns_solve"; echo
	@ cns_string=`date "+%y%m%d%H%M"`; \
	  $(LD) -o cns_solve-$$cns_string.exe $(OBJS) dmemory.o machine_c.o \
	                                      $(LDFLAGS) \
	                                      $(CNS_FFTDIR) $(CNS_FFTLIB); \
	  if [ -x cns_solve-$$cns_string.exe ]; \
	    then echo "created executable file cns_solve-$$cns_string.exe"; \
	         echo ""; cd ../bin; $(RM) -f cns_solve; $(RM) -f cns; \
	                ln -s ../source/cns_solve-$$cns_string.exe cns_solve; \
	                ln -s ../source/cns_solve-$$cns_string.exe cns; \
	  else \
	    echo "problems with new executable - old version retained"; \
	  fi

# display the compilation flags
printflags:
	@ echo; echo "flags:"; \
	  echo " fortran -> [$(F77)] $(F77FLAGS)"; \
	  echo "       c -> [$(CC)] $(CCFLAGS)"; \
	  echo "    link -> [$(LD)] $(LDFLAGS) $(CNS_FFTDIR) $(CNS_FFTLIB)"; \
	  echo

# regenerate makefiles
makefiles: relink
	@ if [ -f Makefile ]; \
	    then mv Makefile Makefile.bak; \
	  fi; \
	  echo 'making Makefile in source directory'; \
	  cat $(CNS_INST)/Makefile.header > Makefile; \
	  echo '    ' >> Makefile; \
	  echo '# Makefile - autobuild '`date` >> Makefile; \
	  echo '    ' >> Makefile; \
	  echo 'OBJS = '`../../bin/objects` >> Makefile; \
	  echo '    ' >> Makefile; \
	  cat $(CNS_SOLVE)/instlib/source/Makefile.proto >> Makefile; \
	  ../../bin/depend *.f >> Makefile

# relink the source files to the compilation directory
relink:
	@ cd $(CNS_SOLVE)/source; \
	  for file in `/bin/ls *.*`; \
	    do if ( /bin/ls $(CNS_SOURCE)/$$file > /dev/null 2>&1 ); \
	         then if [ ! -s $(CNS_SOURCE)/$$file ]; \
	           then echo "removing link for $(CNS_SOURCE)/$$file"; \
	                     $(RM) -f $(CNS_SOURCE)/$$file; \
	         fi; \
	       fi; \
	       if [ ! -f $(CNS_SOURCE)/$$file ]; \
	         then cd $(CNS_SOURCE); \
	         echo "linking ../../source/$$file to source directory"; \
	         ln -s ../../source/$$file .; \
	         cd $(CNS_SOLVE)/source; \
	       fi; \
	  done
	@ cd $(CNS_SOURCE); \
	  for file in `/bin/ls *.*`; \
	    do if [ ! -s $$file ]; \
	      then ofile=`echo $$file | sed -e 's/\.f/\.o/g;s/\.c/\.o/g'`; \
	           echo "removing link for $$file"; \
	           /bin/rm -f $$file; \
	           if [ -f $$ofile ]; \
	             then echo "removing object file $$ofile"; \
	                  /bin/rm -f $$ofile; \
	           fi; \
	      fi; \
	  done

# link machine specific fortran file
machinefile:
	@ echo "linking machine_f.f to source directory"; \
	  cd $(CNS_SOURCE); $(RM) -f machine_f.f; ln -s ../machine_f.f .; \
	  echo "linking machine_c.c to source directory"; \
	  cd $(CNS_SOURCE); $(RM) -f machine_c.c; ln -s ../machine_c.c .

# link fft file to source directory
fftfile:
	@ cd $(CNS_SOURCE); \
	  if [ ! -s fft.f ]; \
	  then \
	    $(RM) -f fft.f; $(RM) -f fft.o; \
	    if [ -n "$(CNS_FFTLIB)" ]; \
	    then echo "linking optimized fft file to source directory"; \
	         ln -s ../fft/fft.f .; \
	    else echo "linking generic fft file to source directory"; \
	         ln -s ../../source/fft.f .; \
	    fi; \
	  else \
	    fftold=`ls -l fft.f | awk '{print $$NF}'`; \
	    if [ -n "$(CNS_FFTLIB)" ]; \
	    then echo "linking optimized fft file to source directory"; \
	         $(RM) -f fft.f; ln -s ../fft/fft.f .; \
	    else echo "linking generic fft file to source directory"; \
	         $(RM) -f fft.f; ln -s ../../source/fft.f .; \
	    fi; \
	    fftnew=`ls -l fft.f | awk '{print $$NF}'`; \
	    if [ $$fftold != $$fftnew ]; then $(RM) -f fft.o; fi; \
	  fi

# remove out of date executables
exepurge:
	@ list=`(ls cns_solve-??????????.exe | sort -r) 2>/dev/null`; \
	  counter=1; \
	  for file in $$list; \
	    do if [ $$counter -gt $${CNS_EXE_LIMIT:=1} ]; \
	      then echo "removing out-of-date executable file $$file"; \
	           rm -f $$file; \
	    fi; \
	    counter=`echo $$counter | awk '{print $$1+1}'`; \
	  done

# remove the most recent executable
remove-exe:
	@ list=`(ls cns_solve-??????????.exe | sort -r ) 2>/dev/null`; \
	  counter=1; \
	  for file in $$list; \
	    do if [ $$counter -eq 1 ]; \
	      then echo "removing most recent executable file $$file"; \
	           rm -f $$file; \
	    fi; \
	    counter=`echo $$counter | awk '{print $$1+1}'`; \
	  done

# test the compilers
compiler-test:
	@ if [ ! -d $(CNS_INST)/compiler-test ]; \
	  then echo "making compiler-test directory in $(CNS_ARCH)"; \
	       mkdir $(CNS_INST)/compiler-test; \
	  fi
	@ cd $(CNS_INST)/compiler-test; \
	  /bin/rm -f $(CNS_INST)/compiler-test/*; \
	  ln -s ../../instlib/compiler-test/* .
	@ echo "testing Fortran and C compilers"; \
	  cd $(CNS_INST)/compiler-test; \
	  make c-test CC="$(CC)" CCFLAGS="$(CCFLAGS)"; \
	  cd $(CNS_INST)/compiler-test; \
	  make fortran-test F77="$(F77)" F77FLAGS="$(F77FLAGS)" \
	                    LD="$(LD)" LDFLAGS="$(LDFLAGS)"

utils:
	@ if [ ! -d $(CNS_INST)/utils ]; \
	  then echo "making utils directory in $(CNS_ARCH)"; \
	       mkdir $(CNS_INST)/utils; \
	  fi
	@ if [ -d $(CNS_SOLVE)/utils ]; \
	  then cd $(CNS_SOLVE)/utils; \
	    for file in `/bin/ls *`; \
	      do if [ ! -f $(CNS_INST)/utils/$$file ]; \
	        then cd $(CNS_INST)/utils; \
	             ln -s ../../utils/$$file .; \
	        fi; \
	    done; \
	    cd $(CNS_INST)/utils; \
	    for file in `/bin/ls *`; \
	      do if [ \( ! -f $(CNS_SOLVE)/utils/$$file   \) -a \
	              \( ! -f $(CNS_SOLVE)/utils/$$file.c \) -a \
	              \( ! -f $(CNS_SOLVE)/utils/$$file.f \) -a \
	              \( ! -f $(CNS_SOLVE)/utils/$$file.l \) ]; \
	        then rm -f $(CNS_INST)/utils/$$file; \
	        fi; \
	    done; \
	    cd $(CNS_SOURCE); make -k utilbin OBJS=none; \
	  fi

# tidy up any stray files
tidy:
	@ $(RM) -f Makefile*bak
	-@ for file in `/bin/ls *.o`; \
	     do sfile=`echo $$file | sed -e 's/\.o/\.f/'`; \
	       cfile=`echo $$file | sed -e 's/\.o/\.c/'`; \
	       if [ \( ! -f $(CNS_SOURCE)/$$sfile \) -a \
	            \( ! -f $(CNS_SOURCE)/$$cfile \) -a \
	            \( ! -f $(CNS_INST)/$$cfile \) ]; \
	         then echo "removing object file $$file"; \
	              /bin/rm -f $$file; \
	       fi; \
	   done

# make space by deleting object files
space:
	@ echo 'removing object files'; /bin/rm -f *.o

# clean up - remove all objects and executables
clean:
	@ echo 'removing object files'; /bin/rm -f *.o; \
	  echo 'removing executable'; /bin/rm -f *.exe

#==============================================================================
 
# source file dependencies
 
angledb.o: angledb.f
aria.o: aria.f
ariass.o: ariass.f
arical.o: arical.f
ariman.o: ariman.f
arivio.o: arivio.f
array.o: array.f
carb.o: carb.f
cluster.o: cluster.f
cns.o: cns.f
connect.o: connect.f
coorio.o: coorio.f
corman.o: corman.f
coup.o: coup.f
cstack.o: cstack.f
cstran.o: cstran.f
dcartesian.o: dcartesian.f
define.o: define.f
diff_anis.o: diff_anis.f
distan.o: distan.f
dsearch.o: dsearch.f
dtorsion_md.o: dtorsion_md.f
dtorsion_top.o: dtorsion_top.f
dynio.o: dynio.f
eangle.o: eangle.f
ebond.o: ebond.f
enbond.o: enbond.f
energy.o: energy.f
etor.o: etor.f
expression.o: expression.f
fastnb.o: fastnb.f
fft.o: fft.f
fftvfy.o: fftvfy.f
flagmap.o: flagmap.f
genic.o: genic.f
heap.o: heap.f
heapvfy.o: heapvfy.f
hybrid_36_f.o: hybrid_36_f.f
imf.o: imf.f
initia.o: initia.f
lbfgs.o: lbfgs.f
lidens.o: lidens.f
machine_f.o: machine_f.f
machvar.o: machvar.f
mapyard.o: mapyard.f
matrix.o: matrix.f
mindist.o: mindist.f
mmdisg.o: mmdisg.f
modes.o: modes.f
mrigid.o: mrigid.f
mtfio.o: mtfio.f
nbonds.o: nbonds.f
ncs.o: ncs.f
noe.o: noe.f
onebond.o: onebond.f
parmio.o: parmio.f
parser.o: parser.f
pick.o: pick.f
pig.o: pig.f
plane.o: plane.f
powell.o: powell.f
print.o: print.f
prot.o: prot.f
psearch.o: psearch.f
psfio.o: psfio.f
rama.o: rama.f
read_write.o: read_write.f
rotate.o: rotate.f
rotlsq.o: rotlsq.f
rotman.o: rotman.f
rsearch.o: rsearch.f
rtfio.o: rtfio.f
segmnt.o: segmnt.f
selrpn.o: selrpn.f
smf.o: smf.f
sort.o: sort.f
string.o: string.f
surfac.o: surfac.f
susc_anis.o: susc_anis.f
test.o: test.f
tsmapd.o: tsmapd.f
tsmapdlm.o: tsmapdlm.f
tsmap.o: tsmap.f
tsmaplm.o: tsmaplm.f
tsmaps.o: tsmaps.f
update.o: update.f
util.o: util.f
vectangl.o: vectangl.f
vector.o: vector.f
vector_func.o: vector_func.f
vfynum.o: vfynum.f
xasymm.o: xasymm.f
xdeclare.o: xdeclare.f
xdo.o: xdo.f
xdofft.o: xdofft.f
xdofried.o: xdofried.f
xfalgebra.o: xfalgebra.f
xfft.o: xfft.f
xfunct.o: xfunct.f
xmalgebra.o: xmalgebra.f
xmask.o: xmask.f
xmaskio.o: xmaskio.f
xmaverage.o: xmaverage.f
xmaxl.o: xmaxl.f
xmphisto.o: xmphisto.f
xmpsele.o: xmpsele.f
xmread.o: xmread.f
xmulti.o: xmulti.f
xmwrite.o: xmwrite.f
xparse.o: xparse.f
xpeakpik.o: xpeakpik.f
xpred.o: xpred.f
xprobab.o: xprobab.f
xprox.o: xprox.f
xray.o: xray.f
xreduce.o: xreduce.f
xreflstar.o: xreflstar.f
xremap.o: xremap.f
xrmani.o: xrmani.f
xropti.o: xropti.f
xscale.o: xscale.f
xsdev.o: xsdev.f
xsfsele.o: xsfsele.f
xshow.o: xshow.f
xsigmaa.o: xsigmaa.f
xskel.o: xskel.f
xspecial.o: xspecial.f
xstats.o: xstats.f
xsymm.o: xsymm.f
xtarget.o: xtarget.f
xutil.o: xutil.f
xyzparse.o: xyzparse.f
 
# include file dependencies
 
angledb.o: angledb.inc cns.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc numbers.inc

aria.o: cns.inc cnst.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc noe.inc

ariass.o: cns.inc cnst.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc noe.inc numbers.inc

arical.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc noe.inc numbers.inc

ariman.o: cns.inc comand.inc consta.inc funct.inc noe.inc vector.inc

arivio.o: cns.inc comand.inc consta.inc mtf.inc numbers.inc pick.inc

carb.o: cns.inc comand.inc consta.inc coord.inc cshifts.inc deriv.inc funct.inc heap.inc mtf.inc numbers.inc

cluster.o: cluster.inc cns.inc comand.inc consta.inc expression.inc funct.inc heap.inc mtf.inc timer.inc xcrystal.inc

cns.o: cns.inc cnst.inc comand.inc funct.inc mtf.inc param.inc seed.inc symbol.inc timer.inc update.inc vector.inc version.inc

connect.o: cns.inc cnst.inc comand.inc consta.inc coordc.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc vector.inc

coorio.o: cns.inc cnst.inc comand.inc coordc.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc timer.inc

corman.o: cns.inc cnst.inc comand.inc consta.inc coordc.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc timer.inc xcrystal.inc

coup.o: cns.inc comand.inc consta.inc coord.inc couplings.inc ctitla.inc deriv.inc funct.inc heap.inc mtf.inc numbers.inc

cstack.o: cns.inc cstack.inc timer.inc

cstran.o: cns.inc cnst.inc comand.inc consta.inc coordc.inc coord.inc deriv.inc ener.inc funct.inc heap.inc mtf.inc nbonds.inc pick.inc update.inc

dcartesian.o: cns.inc cnst.inc comand.inc consta.inc coord.inc deriv.inc ener.inc funct.inc heap.inc mtf.inc timer.inc

define.o: cns.inc comand.inc ctitla.inc funct.inc symbol.inc timer.inc

diff_anis.o: cns.inc comand.inc consta.inc coord.inc deriv.inc diff_anis.inc funct.inc heap.inc mtf.inc numbers.inc

distan.o: cns.inc cnst.inc comand.inc consta.inc coord.inc ener.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc pick.inc

dsearch.o: cns.inc comand.inc consta.inc coord.inc expression.inc funct.inc heap.inc mtf.inc timer.inc xcrystal.inc xtarget.inc

dtorsion_md.o: cns.inc cnst.inc consta.inc coord.inc deriv.inc dtorsion.inc ener.inc mtf.inc timer.inc

dtorsion_top.o: cns.inc cnst.inc comand.inc consta.inc coord.inc deriv.inc dtorsion.inc ener.inc funct.inc heap.inc mtf.inc timer.inc

dynio.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc trtraj.inc

eangle.o: cns.inc consta.inc coord.inc deriv.inc param.inc pick.inc timer.inc update.inc

ebond.o: cns.inc consta.inc coord.inc deriv.inc param.inc pick.inc timer.inc update.inc

enbond.o: cns.inc consta.inc coord.inc deriv.inc ener.inc fastnb.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc param.inc timer.inc xcrystal.inc

energy.o: cns.inc cnst.inc comand.inc consta.inc coord.inc deriv.inc ener.inc funct.inc heap.inc mtf.inc param.inc symbol.inc timer.inc

etor.o: cns.inc consta.inc coord.inc deriv.inc param.inc pick.inc timer.inc update.inc

expression.o: cns.inc comand.inc consta.inc funct.inc

fastnb.o: cns.inc cnst.inc comand.inc consta.inc coord.inc ener.inc fastnb.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc timer.inc xcrystal.inc

fft.o: cns.inc funct.inc heap.inc timer.inc xfft.inc

fftvfy.o: cns.inc funct.inc heap.inc timer.inc xfft.inc

flagmap.o: cns.inc comand.inc flagmap.inc funct.inc heap.inc timer.inc

genic.o: cns.inc cnst.inc comand.inc coordc.inc coord.inc cstack.inc deriv.inc ener.inc funct.inc heap.inc mtf.inc param.inc rtf.inc timer.inc vector.inc

heap.o: cns.inc heap.inc timer.inc

heapvfy.o: cns.inc funct.inc heap.inc timer.inc

imf.o: cns.inc comand.inc flagmap.inc funct.inc heap.inc timer.inc

initia.o: cns.inc cnst.inc coordc.inc coord.inc deriv.inc heap.inc mtf.inc

lbfgs.o: cns.inc comand.inc coord.inc deriv.inc ener.inc funct.inc heap.inc lbfgs.inc machvar.inc mtf.inc

lidens.o: cns.inc comand.inc funct.inc heap.inc numbers.inc timer.inc

machine_f.o: cns.inc comand.inc iochan.inc timer.inc

machvar.o: machvar.inc numbers.inc

mapyard.o: cns.inc comand.inc funct.inc heap.inc mapyard.inc timer.inc

matrix.o: cns.inc funct.inc heap.inc machvar.inc

mindist.o: cns.inc comand.inc coord.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc timer.inc xcrystal.inc

mmdisg.o: cns.inc cnst.inc comand.inc consta.inc coord.inc deriv.inc ener.inc funct.inc heap.inc mmdisg.inc mtf.inc nbonds.inc noe.inc param.inc seed.inc timer.inc update.inc

modes.o: cns.inc comand.inc consta.inc coordc.inc coord.inc funct.inc heap.inc mtf.inc

mrigid.o: cns.inc comand.inc consta.inc coord.inc deriv.inc ener.inc funct.inc heap.inc mrigid.inc mtf.inc timer.inc

mtfio.o: cns.inc comand.inc ctitla.inc ener.inc mtf.inc numbers.inc timer.inc

nbonds.o: cns.inc cnst.inc comand.inc consta.inc coord.inc ener.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc timer.inc xcrystal.inc

ncs.o: cns.inc cnst.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc xcrystal.inc

noe.o: cns.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc noe.inc numbers.inc pick.inc symbol.inc timer.inc

onebond.o: cns.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc numbers.inc onebond.inc

parmio.o: cns.inc comand.inc consta.inc coord.inc cstack.inc ener.inc funct.inc heap.inc learn.inc mtf.inc nbonds.inc param.inc timer.inc update.inc

parser.o: cns.inc comand.inc consta.inc coord.inc ctitla.inc ener.inc funct.inc heap.inc mtf.inc seed.inc symbol.inc timer.inc

pick.o: cns.inc cnst.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc param.inc pick.inc symbol.inc timer.inc update.inc

pig.o: cns.inc cnst.inc comand.inc consta.inc coordc.inc coord.inc ener.inc funct.inc heap.inc mtf.inc nbonds.inc pick.inc update.inc

plane.o: cns.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc plane.inc

powell.o: cns.inc comand.inc coord.inc deriv.inc ener.inc funct.inc heap.inc mtf.inc

print.o: cns.inc cnst.inc comand.inc coord.inc heap.inc noe.inc

prot.o: cns.inc cnst.inc comand.inc coord.inc deriv.inc funct.inc heap.inc hshifts.inc mtf.inc numbers.inc timer.inc

psearch.o: cns.inc comand.inc flagmap.inc funct.inc heap.inc psearch.inc timer.inc

psfio.o: cns.inc comand.inc ener.inc mtf.inc

rama.o: cns.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc numbers.inc rama.inc

read_write.o: cns.inc comand.inc mtf.inc

rotate.o: cns.inc comand.inc consta.inc

rotlsq.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc

rotman.o: cns.inc comand.inc consta.inc xcrystal.inc

rsearch.o: cns.inc comand.inc consta.inc expression.inc funct.inc heap.inc symbol.inc timer.inc xcrystal.inc

rtfio.o: cns.inc comand.inc funct.inc rtf.inc

segmnt.o: cns.inc comand.inc cstack.inc ctitla.inc funct.inc heap.inc mtf.inc timer.inc

selrpn.o: cns.inc cnst.inc comand.inc consta.inc coordc.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc ncs.inc symbol.inc timer.inc vector.inc xcrystal.inc xtarget.inc

smf.o: cns.inc comand.inc flagmap.inc heap.inc timer.inc

sort.o: cns.inc consta.inc funct.inc heap.inc

string.o: funct.inc symbol.inc

surfac.o: cns.inc cnst.inc comand.inc coord.inc funct.inc heap.inc mtf.inc nbonds.inc param.inc

susc_anis.o: cns.inc comand.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc numbers.inc susc_anis.inc

test.o: cns.inc comand.inc coord.inc deriv.inc ener.inc funct.inc heap.inc mtf.inc timer.inc

tsmap.o: cns.inc comand.inc consta.inc flagmap.inc funct.inc heap.inc timer.inc tsmap.inc xfft.inc

tsmaplm.o: cns.inc funct.inc heap.inc tsmap.inc

update.o: cns.inc cnst.inc dtorsion.inc funct.inc heap.inc learn.inc mmdisg.inc mtf.inc nbonds.inc ncs.inc noe.inc plane.inc timer.inc trtraj.inc update.inc vector.inc xcrystal.inc xtarget.inc

util.o: cns.inc comand.inc ctitla.inc heap.inc mtf.inc seed.inc timer.inc version.inc

vectangl.o: cns.inc comand.inc consta.inc coord.inc ctitla.inc deriv.inc funct.inc heap.inc mtf.inc numbers.inc vectangl.inc

vector.o: cns.inc cnst.inc comand.inc consta.inc coordc.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc nbonds.inc symbol.inc timer.inc update.inc vector.inc xcrystal.inc xtarget.inc

vector_func.o: cns.inc comand.inc consta.inc funct.inc mtf.inc seed.inc symbol.inc vector.inc

xasymm.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc xfft.inc

xdeclare.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc xcrystal.inc xtarget.inc

xdo.o: cns.inc comand.inc expression.inc funct.inc heap.inc timer.inc

xdofft.o: cns.inc consta.inc funct.inc heap.inc timer.inc

xdofried.o: cns.inc consta.inc funct.inc heap.inc timer.inc

xfalgebra.o: cns.inc comand.inc consta.inc funct.inc heap.inc seed.inc timer.inc

xfft.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc ncs.inc timer.inc xfft.inc

xfunct.o: cns.inc comand.inc funct.inc

xmalgebra.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc

xmask.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc param.inc timer.inc xmask.inc

xmaskio.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc timer.inc xmask.inc

xmaverage.o: cns.inc comand.inc funct.inc heap.inc timer.inc xmask.inc

xmaxl.o: checof.inc cns.inc consta.inc funct.inc heap.inc xmaxl.inc

xmphisto.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc param.inc timer.inc

xmpsele.o: cns.inc comand.inc expression.inc funct.inc heap.inc timer.inc

xmread.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc

xmulti.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc

xmwrite.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc timer.inc xmask.inc

xparse.o: cns.inc cnst.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc timer.inc xcrystal.inc xfft.inc xtarget.inc

xpeakpik.o: cns.inc comand.inc consta.inc coordc.inc coord.inc funct.inc heap.inc mtf.inc xcrystal.inc xtarget.inc

xpred.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc timer.inc

xprobab.o: cns.inc consta.inc funct.inc heap.inc

xprox.o: cns.inc cnst.inc comand.inc consta.inc coordc.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc ncs.inc param.inc timer.inc vector.inc

xray.o: cns.inc cnst.inc consta.inc coord.inc deriv.inc funct.inc heap.inc mtf.inc nbonds.inc ncs.inc timer.inc xcrystal.inc xtarget.inc

xreduce.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc

xreflstar.o: cns.inc comand.inc funct.inc heap.inc

xremap.o: cns.inc consta.inc funct.inc heap.inc xcrystal.inc

xrmani.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc

xropti.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc ncs.inc numbers.inc timer.inc xcrystal.inc xropti.inc xtarget.inc

xscale.o: cns.inc consta.inc funct.inc heap.inc timer.inc

xsdev.o: cns.inc consta.inc funct.inc heap.inc numbers.inc xcrystal.inc

xsfsele.o: cns.inc comand.inc expression.inc funct.inc heap.inc timer.inc

xshow.o: cns.inc comand.inc consta.inc expression.inc funct.inc heap.inc timer.inc

xsigmaa.o: cns.inc consta.inc funct.inc heap.inc timer.inc xsigmaa.inc

xskel.o: cns.inc comand.inc consta.inc funct.inc heap.inc timer.inc xfft.inc

xspecial.o: cns.inc comand.inc consta.inc coord.inc funct.inc heap.inc mtf.inc

xstats.o: cns.inc comand.inc consta.inc expression.inc funct.inc heap.inc numbers.inc symbol.inc timer.inc

xsymm.o: cns.inc cnst.inc comand.inc funct.inc nbonds.inc timer.inc

xtarget.o: cns.inc consta.inc funct.inc heap.inc timer.inc

xutil.o: cns.inc comand.inc consta.inc

