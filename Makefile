#Makefile for parallel compiling
#=====================================================
# Note: use -C=all to catch array out of bounds errors
#============================================================================ 
# Compiler options
#============================================================================
# IFORT
#FC = mpfort -O3 -qautodbl=dbl4 -compiler xlf90_r -WF,-qfpp -qfixed=72
#FC += -WF,-DMPI -WF,-DFREESLIP
#FC = h5pfc -r8 -ip -ipo -O3 -fpp
#FC = h5pfc -r8 -ip -ipo -O0 -fpp
#FC = h5pfc -r8 -ip -ipo -O3 -fpp -g -traceback -fpe0
#FC = mpif90 -O0 -cpp -Wextra -fdefault-real-8 -fdefault-double-8 -I/usr/include -Wall 
FC = mpif90 -O3 -cpp -Wextra -fdefault-real-8 -fdefault-double-8 -I/usr/include -Wall 
#FC = h5pfc -r8 -O0 -fpp -g -traceback -fpe0 -warn all -debug all -check all
FC += -fopenmp

#FC += -openmp
#FC += -debug all -warn all -check all -g -traceback
#FC += -fpe0 -g -traceback -ftrapuv
#FC += -axAVX -xAVX


# GNU
#FC = mpif90 -O0 -g -cpp -Wextra -fdefault-real-8 -fbounds-check -fdefault-double-8 -ffpe-trap=invalid,zero,overflow -fbacktrace
#FC = mpif90 -O3 -cpp -fdefault-real-8 -fdefault-double-8 -fbounds-check -fbacktrace -Wall -I/usr/include
#FC = mpif90 -O0 -cpp -Wextra -fdefault-real-8 -fbounds-check -fdefault-double-8 -fbacktrace
#FC = mpif90 -O0 -Wall -Wsurprising -Waliasing -Wunused-parameter -fbounds-check -fcheck-array-temporaries -fbacktrace -fdefault-real-8 -fdefault-double-8

#FC += -axAVX -xAVX
#FC += -DSERIAL_DEBUG -DDEBUG
#FC += -DHALO_DEBUG

# IBM
#FC = mpixlf77_r -O3 -qautodbl=dbl4 -WF,-qfpp
#FC += -g -C -qfullpath -qinfo=all
#FC += -WF,-DMPI -WF,-DFREESLIP
#FC += -WF,-DSTATS
#FC += -WF,-DBALANCE
#FC += -WF,-DBLSNAP
#FC += -WF,-DDEBUG
#FC += -qstrict=all

# CRAY

# GENERAL
#FC += -DDEBUG
#FC += -DBLSNAP
#=======================================================================
# Library
#======================================================================
#LINKS = /usr/lib64/liblapack.so.3 /usr/lib64/libblas.so.3 \
	-L$(FFTWLIB) -lfftw3 -lfftw3f
#LINKS = -L$(FFTWLIB) -lfftw3 -L$(MKLLIB) -lmkl_intel_lp64 -lmkl_sequential -lmkl_core  

#LINKS = -lfftw3 -lblas -llapack

#LINKS = -lfftw3 -llapack -lessl 

#LINKS = -lfftw3 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core 
LINKS = -lfftw3 -llapack -lblas -lz -lhdf5_fortran -lhdf5

#LINKS = -lfftw3 -llapack -lblas -lz -lhdf5_fortran -lhdf5
#LINKS = -L${FFTW_LIB} -lfftw3 -L${LAPACK_LIB} -llapack -L${ESSL_LIB} -lesslbg -L${BLAS_LIB} -lblas
#============================================================================ 
# make PROGRAM   
#============================================================================

PROGRAM = boutnp

OBJECTS = AuxiliaryRoutines.o CalcMaxCFL.o SetTempBCs.o CalcPlateNu.o \
          CalcLocalDivergence.o CheckDivergence.o main.o ExplicitTermsVX.o \
          ExplicitTermsVY.o ExplicitTermsVZ.o HdfReadContinua.o \
          ExplicitTermsTemp.o ReadFlowField.o InitVariables.o CreateInitialConditions.o \
          ImplicitAndUpdateVX.o ImplicitAndUpdateVY.o ImplicitAndUpdateVZ.o ResetLogs.o \
          CreateGrid.o DeallocateVariables.o \
          param.o CorrectPressure.o \
          SolveImpEqnUpdate_YZ.o StatRoutines.o \
          SolveImpEqnUpdate_X.o ImplicitAndUpdateTemp.o SolveImpEqnUpdate_Temp.o DebugRoutines.o \
          TimeMarcher.o CorrectVelocity.o GlobalQuantities.o InitPressureSolver.o \
          SolvePressureCorrection.o CalcDissipationNu.o interp.o LocateLargeDivergence.o QuitRoutine.o \
 	    decomp_2d.o decomp_2d_fft.o WriteFlowField.o  \
	    SlabDumpRoutines.o ReadInputFile.o InitTimeMarchScheme.o \
          WriteGridInfo.o StatReadReduceWrite.o HdfRoutines.o \
          MpiAuxRoutines.o
#          alloc.o decomp_2d.o fft_fftw3.o halo.o halo_common.o

MODULES = param.o decomp_2d.o decomp_2d_fft.o 
#============================================================================ 
# Linking    
#============================================================================

$(PROGRAM) : $(MODULES) $(OBJECTS)
	$(FC) $(OP_LINK) $(OBJECTS) -o $@ $(LINKS)  

#============================================================================
#  Dependencies
#============================================================================

param.o: param.F90
	$(FC) -c $(OP_COMP) param.F90

decomp_2d.o: decomp_2d.F90
	$(FC) -c $(OP_COMP) decomp_2d.F90

decomp_2d_fft.o: decomp_2d_fft.F90
	$(FC) -c $(OP_COMP) decomp_2d_fft.F90

%.o:   %.F90 $(MODULES)
	$(FC) -c $(OP_COMP) $< 

%.o:   %.f90 $(MODULES)
	$(FC) -c $(OP_COMP) $< 
        

#============================================================================
#  Clean up
#============================================================================

clean :
	rm *.o  
	rm *.mod
	rm *__genmod*

veryclean :
	rm *.o *.mod *.out *.h5 stats/*.h5 stst3/* boutnp *.dat
