# MaternAI - Complete Maternal Health Monitoring System
# Backend (OSP Graph + Multi-Agent) + Frontend (Jac Client)

# ==================== BACKEND: OSP GRAPH NODES ====================

node patient {
    has patient_id: str;
    has name: str;
    has age: int;
    has pregnancy_week: int;
    has risk_score: float = 0.0;
    has contact_info: str;
    has emergency_contact: str;
    has blood_type: str;
    has allergies: list = [];
}

node health_metric {
    has metric_type: str;
    has value: float;
    has unit: str;
    has timestamp: str;
    has is_abnormal: bool = false;
    has notes: str;
}

node risk_factor {
    has risk_type: str;
    has severity: str;
    has description: str;
    has confidence: float;
    has recommendations: list = [];
}

node appointment {
    has appointment_id: str;
    has date: str;
    has time: str;
    has doctor_name: str;
    has purpose: str;
    has status: str = "scheduled";
    has notes: str;
}

# ==================== BACKEND: EDGES ====================

edge has_metric;
edge has_risk;
edge has_appointment;

# ==================== BACKEND: WALKERS (AGENTS) ====================

# Patient Registration Agent
walker register_patient {
    has patient_name: str;
    has patient_age: int;
    has pregnancy_week: int;
    has contact_info: str;
    has blood_type: str = "unknown";

    with entry {
        patient_id = "PATIENT_" + std.to_str(std.random_int(1000, 9999));
        
        # Correct spawn syntax - create node and connect with edge
        new_patient = spawn here ++> patient(
            patient_id=patient_id,
            name=patient_name,
            age=patient_age,
            pregnancy_week=pregnancy_week,
            risk_score=0.0,
            contact_info=contact_info,
            blood_type=blood_type
        );
        
        report {"status": "success", "patient_id": patient_id, "patient": new_patient};
    }
}

# Health Metric Agent
walker add_metric {
    has patient_id: str;
    has metric_type: str;
    has value: float;
    has unit: str;
    has notes: str = "";

    with entry {
        # Check for abnormal values
        is_abnormal: bool = false;
        if metric_type == "blood_pressure_systolic" and (value > 140 or value < 90) {
            is_abnormal = true;
        } elif metric_type == "glucose" and (value > 140 or value < 70) {
            is_abnormal = true;
        } elif metric_type == "heart_rate" and (value > 100 or value < 60) {
            is_abnormal = true;
        }

        # Corrected spawn syntax - remove "node::"
        new_metric = spawn here ++> health_metric(
            metric_type=metric_type,
            value=value,
            unit=unit,
            timestamp=std.now(),
            is_abnormal=is_abnormal,
            notes=notes
        );
        
        report {"status": "success", "metric": new_metric, "is_abnormal": is_abnormal};
    }
}

# Appointment Scheduler Agent
walker schedule_appointment {
    has patient_id: str;
    has date: str;
    has time: str;
    has doctor_name: str;
    has purpose: str;
    has notes: str = "";

    with entry {
        appointment_id = "APT_" + std.to_str(std.random_int(1000, 9999));
        
        # Correct spawn syntax
        new_appointment = spawn here ++> appointment(
            appointment_id=appointment_id,
            date=date,
            time=time,
            doctor_name=doctor_name,
            purpose=purpose,
            status="scheduled",
            notes=notes
        );
        
        report {"status": "success", "appointment": new_appointment};
    }
}

# Enhanced Risk Analyzer Agent
walker analyze_risks {
    has patient_id: str;

    with entry {
        # Mock comprehensive risk analysis
        detected_risks = [];
        
        # Correct spawn syntax for risk factors
        bp_risk = spawn here ++> risk_factor(
            risk_type="Blood Pressure Monitoring",
            severity="medium",
            description="Regular blood pressure monitoring recommended to prevent gestational hypertension.",
            confidence=0.8,
            recommendations=["Monitor twice daily", "Reduce salt intake", "Stay hydrated"]
        );
        
        detected_risks.append({
            "type": bp_risk.risk_type,
            "severity": bp_risk.severity,
            "description": bp_risk.description,
            "confidence": bp_risk.confidence,
            "recommendations": bp_risk.recommendations
        });

        # Nutrition Risk
        nutrition_risk = spawn here ++> risk_factor(
            risk_type="Nutrition Optimization",
            severity="low",
            description="Consider consulting with a nutritionist for optimal pregnancy diet.",
            confidence=0.7,
            recommendations=["Increase iron-rich foods", "Take prenatal vitamins", "Eat small frequent meals"]
        );
        
        detected_risks.append({
            "type": nutrition_risk.risk_type,
            "severity": nutrition_risk.severity,
            "description": nutrition_risk.description,
            "confidence": nutrition_risk.confidence,
            "recommendations": nutrition_risk.recommendations
        });

        report {
            "status": "success",
            "risks_identified": std.length(detected_risks),
            "risks": detected_risks
        };
    }
}

# Enhanced Dashboard Data Agent
walker get_dashboard_data {
    has patient_id: str;

    with entry {
        # Return comprehensive mock data
        report {
            "patient": {
                "id": "P0001",
                "name": "Sarah Johnson",
                "age": 32,
                "pregnancy_week": 28,
                "risk_score": 0.3,
                "contact_info": "sarah.j@email.com",
                "blood_type": "A+",
                "next_appointment": "2024-12-15"
            },
            "metrics": {
                "blood_pressure_systolic": [
                    {"value": 125, "unit": "mmHg", "timestamp": "2024-11-28", "is_abnormal": false},
                    {"value": 130, "unit": "mmHg", "timestamp": "2024-11-25", "is_abnormal": false}
                ],
                "glucose": [
                    {"value": 95, "unit": "mg/dL", "timestamp": "2024-11-28", "is_abnormal": false},
                    {"value": 105, "unit": "mg/dL", "timestamp": "2024-11-25", "is_abnormal": false}
                ],
                "weight": [
                    {"value": 68.5, "unit": "kg", "timestamp": "2024-11-28", "is_abnormal": false}
                ],
                "heart_rate": [
                    {"value": 85, "unit": "bpm", "timestamp": "2024-11-28", "is_abnormal": false}
                ]
            },
            "appointments": [
                {
                    "date": "2024-12-15",
                    "time": "10:00 AM",
                    "doctor": "Dr. Smith",
                    "purpose": "Regular Checkup",
                    "status": "scheduled"
                }
            ],
            "symptoms": [
                {
                    "description": "Mild back pain",
                    "severity": "mild",
                    "duration": "2 days",
                    "timestamp": "2024-11-27"
                }
            ],
            "risks": [],
            "weekly_tips": [
                "Week 28: Baby's eyes can open and close",
                "Stay hydrated to reduce swelling",
                "Practice pelvic floor exercises"
            ]
        };
    }
}

# ==================== FRONTEND: JAC CLIENT ====================

cl import from react {useState, useEffect}

cl {
    # Enhanced Metric Card Component
    def MetricCard(metric_type: str, metrics: list) -> any {
        latest = {"value": 0, "unit": "", "is_abnormal": false, "timestamp": ""};
        if std.length(metrics) > 0 {
            latest = metrics[std.length(metrics) - 1];
        }
        
        has_abnormal = false;
        for m in metrics {
            if m.get("is_abnormal", false) {
                has_abnormal = true;
                break;
            }
        }
        
        # Define normal ranges for different metrics
        normal_ranges = {
            "blood_pressure_systolic": "90-140 mmHg",
            "glucose": "70-140 mg/dL",
            "heart_rate": "60-100 bpm",
            "weight": "Gradual increase"
        };
        
        normal_range = normal_ranges.get(metric_type, "");

        return <div style={{"background": "white", "borderRadius": "12px", "padding": "20px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)", "border": ("2px solid #F59E0B" if has_abnormal else "2px solid transparent")}}>
            <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "start", "marginBottom": "12px"}}>
                <div style={{"fontSize": "11px", "color": "#6B7280", "textTransform": "uppercase", "fontWeight": "600"}}>
                    {std.replace(metric_type, "_", " ")}
                </div>
                {has_abnormal and 
                    <span style={{"padding": "4px 8px", "background": "#FEF3C7", "color": "#92400E", "borderRadius": "12px", "fontSize": "10px", "fontWeight": "600"}}>
                        Alert
                    </span>
                }
            </div>
            <div style={{"fontSize": "28px", "fontWeight": "bold", "marginBottom": "8px"}}>
                {latest.get("value")}
                <span style={{"fontSize": "14px", "color": "#6B7280", "marginLeft": "4px"}}>
                    {latest.get("unit")}
                </span>
            </div>
            <div style={{"display": "flex", "alignItems": "center", "gap": "6px", "fontSize": "13px", "color": ("#F59E0B" if has_abnormal else "#10B981"), "marginBottom": "4px"}}>
                <span style={{"width": "8px", "height": "8px", "borderRadius": "50%", "background": ("#F59E0B" if has_abnormal else "#10B981")}}></span>
                {("Needs Attention" if has_abnormal else "Normal")}
            </div>
            <div style={{"fontSize": "11px", "color": "#9CA3AF"}}>
                Normal: {normal_range}
            </div>
        </div>;
    }
    
    # Enhanced Risk Card Component
    def RiskCard(risk: dict) -> any {
        colors = {"low": "#10B981", "medium": "#F59E0B", "high": "#EF4444", "critical": "#DC2626"};
        color = colors.get(risk.get("severity", "low"), "#6B7280");
        
        return <div style={{"borderLeft": "4px solid " + color, "background": "#FFF9F5", "padding": "16px", "borderRadius": "8px", "marginBottom": "12px"}}>
            <div style={{"display": "flex", "justifyContent": "space-between", "marginBottom": "8px"}}>
                <div style={{"fontSize": "16px", "fontWeight": "600"}}>
                    {risk.get("type")}
                </div>
                <span style={{"padding": "4px 12px", "borderRadius": "12px", "fontSize": "11px", "fontWeight": "bold", "color": "white", "background": color}}>
                    {std.upper(risk.get("severity", ""))}
                </span>
            </div>
            <p style={{"margin": "0 0 8px 0", "color": "#4B5563", "fontSize": "14px"}}>
                {risk.get("description")}
            </p>
            {std.length(risk.get("recommendations", [])) > 0 and
                <div style={{"marginTop": "12px"}}>
                    <div style={{"fontSize": "12px", "fontWeight": "600", "color": "#6B7280", "marginBottom": "6px"}}>Recommendations:</div>
                    {risk.get("recommendations").map(lambda rec: any -> any {
                        return <div key={rec} style={{"fontSize": "12px", "color": "#4B5563", "padding": "4px 0", "display": "flex", "alignItems": "center", "gap": "6px"}}>
                            <span style={{"color": color}}>•</span> {rec}
                        </div>;
                    })}
                </div>
            }
            <small style={{"color": "#9CA3AF", "display": "block", "marginTop": "8px"}}>
                Confidence: {std.to_str(std.int(risk.get("confidence", 0) * 100))}%
            </small>
        </div>;
    }
    
    # Appointment Card Component
    def AppointmentCard(appointment: dict) -> any {
        return <div style={{"background": "white", "borderRadius": "8px", "padding": "16px", "marginBottom": "12px", "border": "1px solid #E5E7EB"}}>
            <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "8px"}}>
                <div style={{"fontSize": "16px", "fontWeight": "600"}}>
                    {appointment.get("doctor")}
                </div>
                <span style={{"padding": "4px 8px", "background": "#D1FAE5", "color": "#065F46", "borderRadius": "12px", "fontSize": "10px", "fontWeight": "600"}}>
                    {appointment.get("status")}
                </span>
            </div>
            <div style={{"color": "#6B7280", "fontSize": "14px", "marginBottom": "4px"}}>
                {appointment.get("purpose")}
            </div>
            <div style={{"color": "#9CA3AF", "fontSize": "12px"}}>
                {appointment.get("date")} at {appointment.get("time")}
            </div>
        </div>;
    }
    
    # Tip Card Component
    def TipCard(tip: str) -> any {
        return <div style={{"background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "color": "white", "borderRadius": "8px", "padding": "16px", "marginBottom": "8px"}}>
            <div style={{"fontSize": "14px", "fontWeight": "500"}}>
                💡 {tip}
            </div>
        </div>;
    }
    
    # Enhanced Dashboard Component
    def Dashboard(patient_id: str) -> any {
    let [data, setData] = useState(null);
    let [analyzing, setAnalyzing] = useState(false);
    let [activeTab, setActiveTab] = useState("overview");
    
    async def loadData() -> None {
        # ✅ CORRECTED: Fixed spawn syntax
        response = get_dashboard_data(patient_id=patient_id) spawn here;
        if response.reports and std.length(response.reports) > 0 {
            setData(response.reports[0]);
        }
    }
    
    useEffect(lambda -> None {
        loadData();
    }, []);
    
    async def handleAnalyze() -> None {
        setAnalyzing(true);
        # ✅ CORRECTED: Fixed spawn syntax
        response = analyze_risks(patient_id=patient_id) spawn here;
        await loadData();
        setAnalyzing(false);
    }
    
    if not data {
        return <div style={{"textAlign": "center", "padding": "40px"}}>
            <div style={{"fontSize": "48px"}}>⏳</div>
            <p>Loading your health dashboard...</p>
        </div>;
    }
    
    patient = data.get("patient", {});
    metrics = data.get("metrics", {});
    risks = data.get("risks", []);
    appointments = data.get("appointments", []);
    weekly_tips = data.get("weekly_tips", []);
    
    return <div>
        {# Patient Header #}
        <div style={{"display": "flex", "alignItems": "center", "gap": "20px", "padding": "20px", "background": "white", "borderRadius": "16px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)", "marginBottom": "20px"}}>
            <div style={{"width": "70px", "height": "70px", "borderRadius": "50%", "background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "display": "flex", "alignItems": "center", "justifyContent": "center", "fontSize": "28px", "color": "white", "fontWeight": "bold"}}>
                {std.substr(patient.get("name", "P"), 0, 1)}
            </div>
            <div style={{"flex": "1"}}>
                <h2 style={{"margin": "0 0 4px 0", "fontSize": "22px"}}>
                    {patient.get("name", "Patient")}
                </h2>
                <p style={{"margin": "0", "color": "#6B7280", "fontSize": "14px"}}>
                    Age: {patient.get("age")} | Week {patient.get("pregnancy_week")} of 40 | Blood Type: {patient.get("blood_type")}
                </p>
                <p style={{"margin": "4px 0 0 0", "color": "#F8B4D9", "fontSize": "12px", "fontWeight": "600"}}>
                    Next Appointment: {patient.get("next_appointment")}
                </p>
            </div>
            <div style={{"textAlign": "center"}}>
                <div style={{"fontSize": "32px", "fontWeight": "bold", "color": "#F8B4D9"}}>
                    {std.to_str(std.round(patient.get("risk_score", 0), 1))}
                </div>
                <div style={{"fontSize": "11px", "color": "#6B7280"}}>Risk Score</div>
            </div>
        </div>
    </div>;
}
            # Navigation Tabs #}
            <div style={{"display": "flex", "gap": "8px", "marginBottom": "20px", "background": "white", "padding": "8px", "borderRadius": "12px"}}>
                {["overview", "metrics", "appointments"].map(lambda tab: any -> any {
                    return <button
                        key={tab}
                        onClick={lambda -> None { setActiveTab(tab); }}
                        style={{"padding": "12px 20px", "background": (activeTab == tab ? "linear-gradient(135deg, #F8B4D9, #FF9AA2)" : "transparent"), "color": (activeTab == tab ? "white" : "#6B7280"), "border": "none", "borderRadius": "8px", "cursor": "pointer", "fontWeight": "500", "flex": "1"}}
                    >
                        {std.upper(std.substr(tab, 0, 1)) + std.substr(tab, 1)}
                    </button>;
                })}
            </div>
            
            # Tab Content #
            {activeTab == "overview" and 
                <div>
                    # Metrics Grid #
                    <div style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(250px, 1fr))", "gap": "16px", "marginBottom": "20px"}}>
                        {std.keys(metrics).map(lambda t: any -> any {
                            return <MetricCard key={t} metric_type={t} metrics={metrics[t]} />;
                        })}
                    </div>
                    
                    {# Weekly Tips #}
                    <div style={{"background": "white", "borderRadius": "16px", "padding": "24px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)", "marginBottom": "20px"}}>
                        <h3 style={{"margin": "0 0 16px 0", "fontSize": "18px", "display": "flex", "alignItems": "center", "gap": "8px"}}>
                            <span>💡</span> This Week's Tips
                        </h3>
                        <div>
                            {weekly_tips.map(lambda tip: any -> any {
                                return <TipCard key={tip} tip={tip} />;
                            })}
                        </div>
                    </div>
                </div>
            }
            
            {activeTab == "metrics" and 
                <div style={{"background": "white", "borderRadius": "16px", "padding": "24px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}}>
                    <h3 style={{"margin": "0 0 20px 0", "fontSize": "18px"}}>Health Metrics History</h3>
                    <div style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(280px, 1fr))", "gap": "16px"}}>
                        {std.keys(metrics).map(lambda t: any -> any {
                            return <MetricCard key={t} metric_type={t} metrics={metrics[t]} />;
                        })}
                    </div>
                </div>
            }
            
            {activeTab == "appointments" and 
                <div style={{"background": "white", "borderRadius": "16px", "padding": "24px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}}>
                    <h3 style={{"margin": "0 0 16px 0", "fontSize": "18px"}}>Upcoming Appointments</h3>
                    {std.length(appointments) > 0 ? 
                        appointments.map(lambda apt: any -> any {
                            return <AppointmentCard key={apt.get("date") + apt.get("time")} appointment={apt} />;
                        })
                        :
                        <div style={{"textAlign": "center", "padding": "40px", "color": "#6B7280"}}>
                            No upcoming appointments
                        </div>
                    }
                </div>
            }
            
            # AI Risk Analysis Panel #
            <div style={{"background": "white", "borderRadius": "16px", "padding": "24px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}}>
                <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "20px"}}>
                    <h3 style={{"margin": "0", "fontSize": "18px"}}>🧠 AI Risk Analysis</h3>
                    <button
                        onClick={handleAnalyze}
                        disabled={analyzing}
                        style={{"padding": "12px 24px", "background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "color": "white", "border": "none", "borderRadius": "8px", "cursor": ("not-allowed" if analyzing else "pointer"), "opacity": ("0.6" if analyzing else "1")}}
                    >
                        {("🧠 Analyzing..." if analyzing else "🧠 Analyze with AI")}
                    </button>
                </div>
                
                {std.length(risks) == 0 ? (
                    <div style={{"textAlign": "center", "padding": "40px", "color": "#6B7280"}}>
                        <div style={{"width": "64px", "height": "64px", "borderRadius": "50%", "background": "#D1FAE5", "color": "#10B981", "fontSize": "32px", "display": "flex", "alignItems": "center", "justifyContent": "center", "margin": "0 auto 16px"}}>✓</div>
                        <p><strong>No risks detected</strong></p>
                        <small>Click "Analyze with AI" to run comprehensive risk detection</small>
                    </div>
                ) : (
                    <div>
                        {risks.map(lambda r: any -> any {
                            return <RiskCard key={r.get("type")} risk={r} />;
                        })}
                    </div>
                )}
            </div>
        </div>;
    }
    
    # Enhanced Add Metric Form
    def AddMetricForm(patient_id: str, onSuccess: any) -> any {
        let [metricType, setMetricType] = useState("blood_pressure_systolic");
        let [value, setValue] = useState("");
        let [notes, setNotes] = useState("");
        let [message, setMessage] = useState(null);
        
        options = [
            {"value": "blood_pressure_systolic", "label": "Blood Pressure (Systolic)", "unit": "mmHg"},
            {"value": "blood_pressure_diastolic", "label": "Blood Pressure (Diastolic)", "unit": "mmHg"},
            {"value": "glucose", "label": "Blood Glucose", "unit": "mg/dL"},
            {"value": "weight", "label": "Weight", "unit": "kg"},
            {"value": "heart_rate", "label": "Heart Rate", "unit": "bpm"}
        ];
        
        current_metric = null;
        for opt in options {
            if opt["value"] == metricType {
                current_metric = opt;
                break;
            }
        }
        
        async def handleSubmit(e: any) -> None {
            e.preventDefault();
            
            if not value {
                setMessage({"type": "error", "text": "Please enter a value"});
                return;
            }
            
            # Correct spawn syntax for walkers
            response = spawn here walker::add_metric(
                patient_id=patient_id,
                metric_type=metricType,
                value=std.float(value),
                unit=current_metric["unit"],
                notes=notes
            );
            
            setMessage({"type": "success", "text": "Metric recorded successfully! 🎉"});
            setValue("");
            setNotes("");
            setTimeout(lambda -> None { onSuccess(); }, 1500);
        }
        
        return <div style={{"maxWidth": "500px", "margin": "0 auto", "background": "white", "borderRadius": "16px", "padding": "32px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)"}}>
            <h2 style={{"textAlign": "center", "marginBottom": "24px"}}>
                📊 Record Health Metric
            </h2>
            
            <form onSubmit={handleSubmit}>
                <div style={{"marginBottom": "20px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "600", "fontSize": "14px"}}>
                        Metric Type
                    </label>
                    <select
                        value={metricType}
                        onChange={lambda e: any -> None { setMetricType(e.target.value); }}
                        style={{"width": "100%", "padding": "12px", "border": "2px solid #E5E7EB", "borderRadius": "8px", "fontSize": "14px"}}
                    >
                        {options.map(lambda o: any -> any {
                            return <option key={o["value"]} value={o["value"]}>
                                {o["label"]}
                            </option>;
                        })}
                    </select>
                </div>
                
                <div style={{"marginBottom": "20px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "600", "fontSize": "14px"}}>
                        Value ({current_metric["unit"]})
                    </label>
                    <input
                        type="number"
                        step="0.1"
                        value={value}
                        onChange={lambda e: any -> None { setValue(e.target.value); }}
                        placeholder="Enter value"
                        required={true}
                        style={{"width": "100%", "padding": "12px", "border": "2px solid #E5E7EB", "borderRadius": "8px", "fontSize": "14px"}}
                    />
                </div>
                
                <div style={{"marginBottom": "20px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "600", "fontSize": "14px"}}>
                        Notes (Optional)
                    </label>
                    <textarea
                        value={notes}
                        onChange={lambda e: any -> None { setNotes(e.target.value); }}
                        placeholder="Any additional notes..."
                        rows="3"
                        style={{"width": "100%", "padding": "12px", "border": "2px solid #E5E7EB", "borderRadius": "8px", "fontSize": "14px", "resize": "vertical"}}
                    />
                </div>
                
                {message and (
                    <div style={{"padding": "12px", "borderRadius": "8px", "marginBottom": "20px", "background": ("#D1FAE5" if message["type"] == "success" else "#FEE2E2"), "color": ("#059669" if message["type"] == "success" else "#DC2626")}}>
                        {message["text"]}
                    </div>
                )}
                
                <button
                    type="submit"
                    style={{"width": "100%", "padding": "14px", "background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "color": "white", "border": "none", "borderRadius": "8px", "fontSize": "14px", "fontWeight": "500", "cursor": "pointer"}}
                >
                    Record Metric
                </button>
            </form>
        </div>;
    }
    
    # Enhanced Main App Component
    def app() -> any {
        let [view, setView] = useState("dashboard");
        patient_id = "P0001";
        
        return <div style={{"maxWidth": "1200px", "margin": "0 auto", "padding": "20px", "fontFamily": "'Segoe UI', system-ui, sans-serif", "background": "linear-gradient(135deg, #FFF9F5 0%, #F3F4F6 100%)", "minHeight": "100vh"}}>
            # Enhanced Header #
            <div style={{"background": "white", "borderRadius": "16px", "padding": "24px", "boxShadow": "0 2px 8px rgba(0,0,0,0.08)", "marginBottom": "20px", "display": "flex", "justifyContent": "space-between", "alignItems": "center"}}>
                <div style={{"display": "flex", "alignItems": "center", "gap": "12px"}}>
                    <div style={{"fontSize": "32px", "width": "48px", "height": "48px", "borderRadius": "12px", "background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "display": "flex", "alignItems": "center", "justifyContent": "center"}}>
                        🤰
                    </div>
                    <div>
                        <h1 style={{"margin": "0", "fontSize": "24px"}}>MaternAI</h1>
                        <p style={{"margin": "0", "fontSize": "12px", "color": "#6B7280"}}>
                            Smart Maternal Health Monitoring System
                        </p>
                    </div>
                </div>
                <div style={{"display": "flex", "gap": "8px"}}>
                    <span style={{"padding": "6px 12px", "background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "color": "white", "borderRadius": "20px", "fontSize": "11px", "fontWeight": "600"}}>5 AGENTS</span>
                    <span style={{"padding": "6px 12px", "background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "color": "white", "borderRadius": "20px", "fontSize": "11px", "fontWeight": "600"}}>OSP GRAPH</span>
                    <span style={{"padding": "6px 12px", "background": "linear-gradient(135deg, #F8B4D9, #FF9AA2)", "color": "white", "borderRadius": "20px", "fontSize": "11px", "fontWeight": "600"}}>AI POWERED</span>
                </div>
            </div>
            
            # Navigation #
            <div style={{"display": "flex", "gap": "12px", "marginBottom": "20px"}}>
                <button
                    onClick={lambda -> None { setView("dashboard"); }}
                    style={{"padding": "12px 24px", "background": ("linear-gradient(135deg, #F8B4D9, #FF9AA2)" if view == "dashboard" else "white"), "color": ("white" if view == "dashboard" else "#F8B4D9"), "border": ("none" if view == "dashboard" else "2px solid #F8B4D9"), "borderRadius": "8px", "fontSize": "14px", "fontWeight": "500", "cursor": "pointer"}}
                >
                    📊 Dashboard
                </button>
                <button
                    onClick={lambda -> None { setView("add"); }}
                    style={{"padding": "12px 24px", "background": ("linear-gradient(135deg, #F8B4D9, #FF9AA2)" if view == "add" else "white"), "color": ("white" if view == "add" else "#F8B4D9"), "border": ("none" if view == "add" else "2px solid #F8B4D9"), "borderRadius": "8px", "fontSize": "14px", "fontWeight": "500", "cursor": "pointer"}}
                >
                    ➕ Add Metric
                </button>
            </div>
            
            # Main Content #
            {view == "dashboard" ? (
                <Dashboard patient_id={patient_id} />
            ) : (
                <AddMetricForm
                    patient_id={patient_id}
                    onSuccess={lambda -> None { setView("dashboard"); }}
                />
            )}
        </div>;
    }
}

# ==================== INITIALIZATION ====================

walker init {
    with entry {
        # Create demo patient - Correct spawn syntax
        spawn here walker::register_patient(
            patient_name="Sarah Johnson",
            patient_age=32,
            pregnancy_week=28,
            contact_info="sarah.j@email.com",
            blood_type="A+"
        );

        # Add sample metrics
        spawn here walker::add_metric(
            patient_id="P0001",
            metric_type="blood_pressure_systolic",
            value=125.0,
            unit="mmHg"
        );

        spawn here walker::add_metric(
            patient_id="P0001",
            metric_type="glucose",
            value=115.0,
            unit="mg/dL"
        );

        spawn here walker::add_metric(
            patient_id="P0001",
            metric_type="weight",
            value=68.5,
            unit="kg"
        );

        # Schedule sample appointment
        spawn here walker::schedule_appointment(
            patient_id="P0001",
            date="2024-12-15",
            time="10:00 AM",
            doctor_name="Dr. Smith",
            purpose="Regular Checkup"
        );

        std.out("🚀 MaternAI Enhanced System Started!");
        std.out("📊 Multiple agents initialized");
        std.out("🏥 Comprehensive maternal health monitoring ready");
        std.out("🌐 Visit http://localhost:8000");
    }
}