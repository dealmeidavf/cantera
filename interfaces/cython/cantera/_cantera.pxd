from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool as cbool
from cpython cimport bool as pybool

import numpy as np
cimport numpy as np

cdef extern from "cantera/base/xml.h" namespace "Cantera":
    cdef cppclass XML_Node:
        XML_Node* findByName(string)
        XML_Node* findID(string)
        int nChildren()

cdef extern from "cantera/base/ctml.h" namespace "ctml":
    XML_Node getCtmlTree(string) except +

cdef extern from "cantera/base/global.h" namespace "Cantera":
    cdef void CxxAddDirectory "Cantera::addDirectory" (string)

cdef extern from "cantera/thermo/mix_defs.h":
    cdef int thermo_type_ideal_gas "Cantera::cIdealGas"
    cdef int thermo_type_surf "Cantera::cSurf"
    cdef int thermo_type_edge "Cantera::cEdge"

    cdef int kinetics_type_gas "Cantera::cGasKinetics"
    cdef int kinetics_type_interface "Cantera::cInterfaceKinetics"
    cdef int kinetics_type_edge "Cantera::cEdgeKinetics"


cdef extern from "funcWrapper.h":
    ctypedef double (*callback_wrapper)(double, void*, void**)
    cdef int translate_exception()

    cdef cppclass CxxFunc1 "Func1Py":
        CxxFunc1(callback_wrapper, void*)
        double eval(double) except +translate_exception


cdef extern from "cantera/thermo/ThermoPhase.h" namespace "Cantera":
    cdef cppclass CxxThermoPhase "Cantera::ThermoPhase":
        CxxThermoPhase()

        # miscellaneous
        int eosType()
        string report(cbool) except +
        string name()
        void setName(string)
        double minTemp() except +
        double maxTemp() except +
        double refPressure() except +
        cbool getElementPotentials(double*) except +

        # basic thermodynamic properties
        double temperature() except +
        double pressure() except +
        double density() except +
        double molarDensity() except +
        double molarVolume() except +
        double isothermalCompressibility() except +
        double thermalExpansionCoeff() except +
        double electricPotential() except +
        void setElectricPotential(double) except +

        # element properties
        size_t nElements()
        size_t elementIndex(string)
        string elementName(size_t) except +

        # species properties
        size_t nSpecies()
        size_t speciesIndex(string)
        string speciesName(size_t) except +
        double nAtoms(size_t, size_t) except +
        void getAtoms(size_t, double*) except +

        double molecularWeight(size_t) except +
        double meanMolecularWeight()

        # composition
        void setMassFractionsByName(string) except +
        double massFraction(size_t) except +
        double massFraction(string) except +

        void setMoleFractionsByName(string) except +
        void getMoleFractions(double*) except +
        double moleFraction(size_t) except +
        double moleFraction(string) except +

        double concentration(size_t) except +

        # state setters
        void setState_TR(double, double) except +
        void setState_TP(double, double) except +
        void setState_HP(double, double) except +
        void setState_UV(double, double) except +
        void setState_SP(double, double) except +

        # molar thermodynamic properties:
        double enthalpy_mole() except +
        double intEnergy_mole() except +
        double entropy_mole() except +
        double gibbs_mole() except +
        double cp_mole() except +
        double cv_mole() except +

        # specific (mass) properties:
        double enthalpy_mass() except +
        double intEnergy_mass() except +
        double entropy_mass() except +
        double gibbs_mass() except +
        double cp_mass() except +
        double cv_mass() except +

        # PureFluid properties
        double critTemperature() except +
        double critPressure() except +
        double critDensity() except +

        double satTemperature(double P) except +
        double satPressure(double T) except +
        double vaporFraction() except +

        void setState_Tsat(double T, double x) except +
        void setState_Psat(double P, double x) except +


cdef extern from "cantera/thermo/IdealGasPhase.h":
    cdef cppclass CxxIdealGasPhase "Cantera::IdealGasPhase"


cdef extern from "cantera/thermo/SurfPhase.h":
    cdef cppclass CxxSurfPhase "Cantera::SurfPhase":
        CxxSurfPhase()
        double siteDensity()
        void setSiteDensity(double)
        void setCoverages(double*) except +
        void getCoverages(double*) except +


cdef extern from "cantera/kinetics/Kinetics.h" namespace "Cantera":
    cdef cppclass CxxKinetics "Cantera::Kinetics":
        CxxKinetics()
        int type()
        int nTotalSpecies()
        int nReactions()
        int nPhases()
        int reactionPhaseIndex()
        int kineticsSpeciesIndex(int, int)

        CxxThermoPhase& thermo(int)

        cbool isReversible(int) except +
        int reactionType(int) except +
        string reactionString(int) except +
        double reactantStoichCoeff(int, int) except +
        double productStoichCoeff(int, int) except +

        double multiplier(int)
        void setMultiplier(int, double)


cdef extern from "cantera/kinetics/InterfaceKinetics.h":
    cdef cppclass CxxInterfaceKinetics "Cantera::InterfaceKinetics":
        void advanceCoverages(double) except +


cdef extern from "cantera/transport/TransportFactory.h":
    cdef string transportModelName "Cantera::TransportFactory::modelName" (int)


cdef extern from "cantera/transport/TransportBase.h" namespace "Cantera":
    cdef cppclass CxxTransport "Cantera::Transport":
        CxxTransport(CxxThermoPhase*)
        int model()
        double viscosity() except +
        double thermalConductivity() except +


cdef extern from "cantera/transport/DustyGasTransport.h" namespace "Cantera":
    cdef cppclass CxxDustyGasTransport "Cantera::DustyGasTransport":
        void setPorosity(double) except +
        void setTortuosity(double) except +
        void setMeanPoreRadius(double) except +
        void setMeanParticleDiameter(double) except +
        void setPermeability(double) except +


cdef extern from "cantera/equil/MultiPhase.h" namespace "Cantera":
    cdef cppclass CxxMultiPhase "Cantera::MultiPhase":
        CxxMultiPhase()
        void addPhase(CxxThermoPhase*, double) except +
        void init() except +

        size_t nSpecies()
        size_t nElements()
        size_t nPhases()
        size_t elementIndex(string) except +
        size_t speciesIndex(size_t, size_t) except +
        string speciesName(size_t) except +
        double nAtoms(size_t, size_t) except +

        double phaseMoles(size_t) except +
        void setPhaseMoles(size_t, double) except +
        void setMoles(double*) except +
        void setMolesByName(string) except +

        double speciesMoles(size_t) except +
        double elementMoles(size_t) except +

        void setTemperature(double) except +
        double temperature()
        void setPressure(double) except +
        double pressure()

        double minTemp() except +
        double maxTemp() except +
        double charge() except +
        double phaseCharge(size_t) except +
        void getChemPotentials(double*) except +
        double enthalpy() except +
        double entropy() except +
        double gibbs() except +
        double cp() except +
        double volume() except +

cdef extern from "cantera/equil/equil.h" namespace "Cantera":
    int equilibrate(CxxThermoPhase&, char*, int, double, int, int, int) except +

cdef extern from "cantera/equil/vcs_MultiPhaseEquil.h" namespace "Cantera":
    int vcs_equilibrate(CxxMultiPhase&, char*, int, int, int, double, int, int, int) except +


cdef extern from "cantera/zeroD/ReactorBase.h" namespace "Cantera":
    cdef cppclass CxxWall "Cantera::Wall"
    cdef cppclass CxxFlowDevice "Cantera::FlowDevice"

    cdef cppclass CxxReactorBase "Cantera::ReactorBase":
        CxxReactorBase()
        void setThermoMgr(CxxThermoPhase&) except +
        void restoreState() except +
        double volume()
        string name()
        void setName(string)
        void setInitialVolume(double)


cdef extern from "cantera/zeroD/Reactor.h":
    cdef cppclass CxxReactor "Cantera::Reactor" (CxxReactorBase):
        CxxReactor()
        void setKineticsMgr(CxxKinetics&)
        void setEnergy(int)
        cbool energyEnabled()

        void addSensitivityReaction(size_t) except +
        size_t nSensParams()


cdef extern from "cantera/zeroD/FlowReactor.h":
    cdef cppclass CxxFlowReactor "Cantera::FlowReactor" (CxxReactor):
        CxxFlowReactor()
        void setMassFlowRate(double) except +
        double speed()
        double distance()


cdef extern from "cantera/zeroD/Wall.h":
    cdef cppclass CxxWall "Cantera::Wall":
        CxxWall()
        cbool install(CxxReactorBase&, CxxReactorBase&)
        void setExpansionRateCoeff(double)
        double getExpansionRateCoeff()
        double area()
        void setArea(double)
        double getArea()
        void setHeatTransferCoeff(double)
        double getHeatTransferCoeff()
        void setEmissivity(double) except +
        double getEmissivity()
        void setVelocity(CxxFunc1*)
        void setHeatFlux(CxxFunc1*)
        void setKinetics(CxxKinetics*, CxxKinetics*)
        void setCoverages(int, double*)
        void syncCoverages(int)
        double vdot(double)
        double Q(double)

        void addSensitivityReaction(int, size_t) except +
        size_t nSensParams(int)


cdef extern from "cantera/zeroD/flowControllers.h":
    cdef cppclass CxxFlowDevice "Cantera::FlowDevice":
        CxxFlowDevice()
        double massFlowRate(double)
        cbool install(CxxReactorBase&, CxxReactorBase&)
        void setFunction(CxxFunc1*)
        void setParameters(int, double*)

    cdef cppclass CxxMassFlowController "Cantera::MassFlowController" (CxxFlowDevice):
        CxxMassFlowController()

    cdef cppclass CxxValve "Cantera::Valve" (CxxFlowDevice):
        CxxValve()

    cdef cppclass CxxPressureController "Cantera::PressureController" (CxxFlowDevice):
        CxxPressureController()
        void setMaster(CxxFlowDevice*)


cdef extern from "cantera/zeroD/ReactorNet.h":
    cdef cppclass CxxReactorNet "Cantera::ReactorNet":
        CxxReactorNet()
        void addReactor(CxxReactorBase*)
        void advance(double) except +
        double step(double) except +
        double time()
        void setInitialTime(double)
        void setTolerances(double, double)
        double rtol()
        double atol()
        void setMaxTimeStep(double)
        cbool verbose()
        void setVerbose(cbool)
        size_t neq()

        void setSensitivityTolerances(double, double)
        double rtolSensitivity()
        double atolSensitivity()
        double sensitivity(size_t, size_t) except +
        double sensitivity(string&, size_t, int) except +
        size_t nparams()
        string sensitivityParameterName(size_t) except +


cdef extern from "cantera/thermo/ThermoFactory.h" namespace "Cantera":
    cdef CxxThermoPhase* newPhase(string, string) except +
    cdef CxxThermoPhase* newPhase(XML_Node&) except +

cdef extern from "cantera/kinetics/KineticsFactory.h" namespace "Cantera":
    cdef CxxKinetics* newKineticsMgr(XML_Node&, vector[CxxThermoPhase*]) except +

cdef extern from "cantera/transport/TransportFactory.h" namespace "Cantera":
    cdef CxxTransport* newDefaultTransportMgr(CxxThermoPhase*) except +
    cdef CxxTransport* newTransportMgr(string, CxxThermoPhase*) except +

cdef extern from "cantera/zeroD/ReactorFactory.h" namespace "Cantera":
    cdef CxxReactorBase* newReactor(string) except +

cdef extern from "cantera/oneD/Domain1D.h":
    cdef cppclass CxxDomain1D "Cantera::Domain1D":
        size_t domainIndex()
        size_t nComponents()
        size_t nPoints()
        string componentName(size_t) except +
        size_t componentIndex(string) except +
        void setBounds(size_t, double, double)
        double upperBound(size_t)
        double lowerBound(size_t)
        void setTolerances(size_t, double, double, int)
        double rtol(size_t)
        double atol(size_t)
        double grid(size_t)
        void setupGrid(size_t, double*) except +
        void setID(string)
        string& id()
        void setDesc(string)
        string& desc()


cdef extern from "cantera/oneD/Inlet1D.h":
    cdef cppclass CxxBdry1D "Cantera::Bdry1D":
        double temperature()
        void setTemperature(double)
        double mdot()
        void setMdot(double)
        size_t nSpecies()
        void setMoleFractions(double*) except +
        void setMoleFractions(string) except +
        double massFraction(size_t)

    cdef cppclass CxxInlet1D "Cantera::Inlet1D":
        CxxInlet1D()
        double spreadRate()
        void setSpreadRate(double)

    cdef cppclass CxxOutlet1D "Cantera::Outlet1D":
        CxxOutlet1D()

    cdef cppclass CxxOutletRes1D "Cantera::OutletRes1D":
        CxxOutletRes1D()

    cdef cppclass CxxSymm1D "Cantera::Symm1D":
        CxxSymm1D()

    cdef cppclass CxxSurf1D "Cantera::Surf1D":
        CxxSurf1D()

    cdef cppclass CxxReactingSurf1D "Cantera::ReactingSurf1D":
        CxxRreactingSurf1D()
        void setKineticsMgr(CxxInterfaceKinetics*) except +
        void enableCoverageEquations(cbool) except +


cdef extern from "cantera/oneD/StFlow.h":
    cdef cppclass CxxStFlow "Cantera::StFlow":
        CxxStFlow(CxxIdealGasPhase*, int, int)
        void setKinetics(CxxKinetics&) except +
        void setTransport(CxxTransport&, cbool) except +
        void setTransport(CxxTransport&) except +
        void setPressure(double)
        double pressure()
        void setFixedTempProfile(vector[double]&, vector[double]&)
        void solveEnergyEqn()
        void fixTemperature()
        cbool doEnergy(size_t)
        void enableSoret(cbool)
        cbool withSoret()

    cdef cppclass CxxFreeFlame "Cantera::FreeFlame":
        CxxFreeFlame(CxxIdealGasPhase*, int, int)

    cdef cppclass CxxAxiStagnFlow "Cantera::AxiStagnFlow":
        CxxAxiStagnFlow(CxxIdealGasPhase*, int, int)


cdef extern from "cantera/oneD/Sim1D.h":
    cdef cppclass CxxSim1D "Cantera::Sim1D":
        CxxSim1D(vector[CxxDomain1D*]&) except +
        void setValue(size_t, size_t, size_t, double) except +
        void setProfile(size_t, size_t, vector[double]&, vector[double]&) except +
        void setFlatProfile(size_t, size_t, double) except +
        void showSolution() except +
        void setTimeStep(double, size_t, int*) except +
        void getInitialSoln() except +
        void solve(int, cbool) except +
        void refine(int) except +
        void setRefineCriteria(size_t, double, double, double, double)
        void save(string, string, string, int) except +
        void restore(string, string, int) except +
        void writeStats(int) except +
        int domainIndex(string) except +
        double value(size_t, size_t, size_t) except +
        double workValue(size_t, size_t, size_t) except +
        void eval(double, int) except +
        void setJacAge(int, int)
        void setTimeStepFactor(double)
        void setMinTimeStep(double)
        void setMaxTimeStep(double)
        void setFixedTemperature(double)


cdef extern from "wrappers.h":
    # config definitions
    cdef string get_cantera_version()
    cdef int get_sundials_version()

    # ThermoPhase composition
    cdef void thermo_getMassFractions(CxxThermoPhase*, double*) except +
    cdef void thermo_setMassFractions(CxxThermoPhase*, double*) except +
    cdef void thermo_getMoleFractions(CxxThermoPhase*, double*) except +
    cdef void thermo_setMoleFractions(CxxThermoPhase*, double*) except +
    cdef void thermo_getConcentrations(CxxThermoPhase*, double*) except +
    cdef void thermo_setConcentrations(CxxThermoPhase*, double*) except +

    # ThermoPhase partial molar properties
    cdef void thermo_getChemPotentials(CxxThermoPhase*, double*) except +
    cdef void thermo_getElectrochemPotentials(CxxThermoPhase*, double*) except +
    cdef void thermo_getPartialMolarEnthalpies(CxxThermoPhase*, double*) except +
    cdef void thermo_getPartialMolarEntropies(CxxThermoPhase*, double*) except +
    cdef void thermo_getPartialMolarIntEnergies(CxxThermoPhase*, double*) except +
    cdef void thermo_getPartialMolarCp(CxxThermoPhase*, double*) except +
    cdef void thermo_getPartialMolarVolumes(CxxThermoPhase*, double*) except +

    # ThermoPhase partial non-dimensional properties
    void thermo_getEnthalpy_RT(CxxThermoPhase*, double*) except +
    void thermo_getEntropy_R(CxxThermoPhase*, double*) except +
    void thermo_getIntEnergy_RT(CxxThermoPhase*, double*) except +
    void thermo_getGibbs_RT(CxxThermoPhase*, double*) except +
    void thermo_getCp_R(CxxThermoPhase*, double*) except +

    # other ThermoPhase methods
    cdef void thermo_getMolecularWeights(CxxThermoPhase*, double*) except +

    # Kinetics per-reaction properties
    cdef void kin_getFwdRatesOfProgress(CxxKinetics*, double*) except +
    cdef void kin_getRevRatesOfProgress(CxxKinetics*, double*) except +
    cdef void kin_getNetRatesOfProgress(CxxKinetics*, double*) except +

    cdef void kin_getEquilibriumConstants(CxxKinetics*, double*) except +
    cdef void kin_getActivationEnergies(CxxKinetics*, double*) except +
    cdef void kin_getFwdRateConstants(CxxKinetics*, double*) except +
    cdef void kin_getRevRateConstants(CxxKinetics*, double*) except +

    cdef void kin_getDeltaEnthalpy(CxxKinetics*, double*) except +
    cdef void kin_getDeltaGibbs(CxxKinetics*, double*) except +
    cdef void kin_getDeltaEntropy(CxxKinetics*, double*) except +
    cdef void kin_getDeltaSSEnthalpy(CxxKinetics*, double*) except +
    cdef void kin_getDeltaSSGibbs(CxxKinetics*, double*) except +
    cdef void kin_getDeltaSSEntropy(CxxKinetics*, double*) except +

    # Kinetics per-species properties
    cdef void kin_getCreationRates(CxxKinetics*, double*) except +
    cdef void kin_getDestructionRates(CxxKinetics*, double*) except +
    cdef void kin_getNetProductionRates(CxxKinetics*, double*) except +

    # Transport properties
    cdef void tran_getMixDiffCoeffs(CxxTransport*, double*) except +
    cdef void tran_getMixDiffCoeffsMass(CxxTransport*, double*) except +
    cdef void tran_getMixDiffCoeffsMole(CxxTransport*, double*) except +
    cdef void tran_getThermalDiffCoeffs(CxxTransport*, double*) except +

    cdef void tran_getMultiDiffCoeffs(CxxTransport*, size_t, double*) except +
    cdef void tran_getBinaryDiffCoeffs(CxxTransport*, size_t, double*) except +


cdef string stringify(x)

cdef class _SolutionBase:
    cdef CxxThermoPhase* thermo
    cdef CxxKinetics* kinetics
    cdef CxxTransport* transport
    cdef int thermoBasis
    cdef np.ndarray _selectedSpecies
    cdef object parent

cdef class Kinetics(_SolutionBase):
    pass

cdef class Func1:
    cdef CxxFunc1* func
    cdef object callable
    cdef object exception

cdef class ReactorBase:
    cdef CxxReactorBase* rbase
    cdef object _thermo
    cdef list _inlets
    cdef list _outlets
    cdef list _walls

cdef class Reactor(ReactorBase):
    cdef CxxReactor* reactor
    cdef object _kinetics

cdef class WallSurface:
    cdef CxxWall* cxxwall
    cdef object wall
    cdef int side
    cdef Kinetics _kinetics

cdef class Wall:
    cdef CxxWall* wall
    cdef WallSurface leftSurface
    cdef WallSurface rightSurface
    cdef object _velocityFunc
    cdef object _heatFluxFunc
    cdef str name

cdef class FlowDevice:
    cdef CxxFlowDevice* dev
    cdef Func1 _rateFunc
    cdef str name