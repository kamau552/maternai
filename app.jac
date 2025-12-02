"""
MaternAI - Hackathon Edition
"""

# ==================== 1. OSP GRAPH DEFINITIONS ====================

node Patient {
    has name: str;
    has age: int;
    has pregnancy_week: int;
}

node HealthMetric {
    has metric_type: str;
    has value: float;
    has unit: str;
    has timestamp: str;
    has is_abnormal: bool;
}

node RiskReport {
    has summary: str;
    has severity: str;
    has recommendation: str;
}

# ==================== 2. AGENTS (WALKERS) ====================

# AGENT 1: Recorder
walker recorder {
    has patient_id: str;
    has metric_type: str;
    has value: float;
    has unit: str;

    can record_metric with `root entry {
        # 1. Find Patient (Using Safe Selector Syntax)
        patient_node = None;
        # We grab all patients first to avoid parser errors in the loop
        all_patients = [-->](`?Patient);
        
        for p in all_patients {
            if p.name == self.patient_id {
                patient_node = p;
                break;
            }
        }
        
        if not patient_node {
            patient_node = here ++> Patient(
                name=self.patient_id, 
                age=30, 
                pregnancy_week=20
            );
        }

        # 2. Check Logic (Pure Jac)
        is_bad = False;
        if self.metric_type == "BP Systolic" {
            if self.value > 140.0 { is_bad = True; }
            if self.value < 90.0 { is_bad = True; }
        }

        # 3. Add Metric
        patient_node ++> HealthMetric(
            metric_type=self.metric_type,
            value=self.value,
            unit=self.unit,
            timestamp="Just Now",
            is_abnormal=is_bad
        );

        report {"status": "recorded"};
    }
}

# AGENT 2: AI Doctor
walker doctor_ai {
    has patient_id: str;

    can analyze with `root entry {
        patient_node = None;
        history = [];

        # 1. Traverse to Patient
        all_patients = [-->](`?Patient);
        
        for p in all_patients {
            if p.name == self.patient_id {
                patient_node = p;
                
                # 2. Traverse to Metrics (Safe Selector)
                # We perform the collection from the 'p' context
                metrics = [p -->](`?HealthMetric);
                
                for m in metrics {
                    # Construct string manually to avoid parser complex string math
                    val_str = str(m.value);
                    entry = m.metric_type + ": " + val_str;
                    history.append(entry);
                }
            }
        }

        if not patient_node {
            report {"error": "Patient not found"};
            disengage;
        }

        # 3. PURE JAC ANALYSIS LOGIC (Inline)
        severity = "Low";
        
        # Scan history for high risk string
        for h in history {
            # "145" is our trigger for high BP in this demo
            if "145" in h { 
                severity = "High"; 
            }
        }

        if severity == "Low" {
            if len(history) > 2 {
                severity = "Medium";
            }
        }
        
        # Construct summary
        count = str(len(history));
        summary = "Analyzed " + count + " metrics. Risk level: " + severity;
        
        rec = "Continue monitoring.";
        if severity == "High" {
            rec = "Schedule checkup immediately.";
        }

        # 4. Save Report
        patient_node ++> RiskReport(
            summary=summary,
            severity=severity,
            recommendation=rec
        );

        report {
            "summary": summary,
            "severity": severity,
            "recommendation": rec
        };
    }
}

# AGENT 3: Reporter
walker reporter {
    has patient_id: str;

    can fetch_dashboard with `root entry {
        data = {
            "patient": {},
            "metrics": [],
            "risks": []
        };

        all_patients = [-->](`?Patient);

        for p in all_patients {
            if p.name == self.patient_id {
                data["patient"] = {
                    "name": p.name,
                    "age": p.age,
                    "week": p.pregnancy_week
                };

                # Fetch Metrics
                patient_metrics = [p -->](`?HealthMetric);
                for m in patient_metrics {
                    data["metrics"].append({
                        "type": m.metric_type,
                        "value": m.value,
                        "unit": m.unit,
                        "is_abnormal": m.is_abnormal
                    });
                }

                # Fetch Risks
                patient_risks = [p -->](`?RiskReport);
                for r in patient_risks {
                    data["risks"].append({
                        "severity": r.severity,
                        "summary": r.summary
                    });
                }
            }
        }
        report data;
    }
}

# ==================== 3. FRONTEND ====================

cl {
    import from react { useState, useEffect }

    def Dashboard() -> any {
        let [patientId, setId] = useState("Sarah");
        let [data, setData] = useState(None);
        let [loading, setLoading] = useState(False);

        def refreshData() -> None {
            setLoading(True);
            result = spawn root reporter(patient_id=patientId);
            setLoading(False);
            if result.reports and len(result.reports) > 0 {
                setData(result.reports[0]);
            }
        }

        def addMetric(type: str, val: float, unit: str) -> None {
            spawn root recorder(
                patient_id=patientId,
                metric_type=type,
                value=val,
                unit=unit
            );
            refreshData();
        }

        def runAI() -> None {
            setLoading(True);
            spawn root doctor_ai(patient_id=patientId);
            setLoading(False);
            refreshData();
        }

        useEffect(lambda -> None { refreshData(); }, []);

        if not data { 
            return <div style={{"padding":"50px", "textAlign":"center"}}><h2>{loading ? "Loading..." : "Initializing Data..."}</h2></div>; 
        }

        patient = data.get("patient", {"name": "Unknown", "age": 0, "week": 0});
        metrics = data.get("metrics", []);
        risks = data.get("risks", []);
        
        # Sort metrics by value to put high risk metrics at the top of history
        metrics_sorted = sorted(
            metrics, 
            lambda m: float -> float { return m.get("is_abnormal", False) ? -1 : 1; }
        );

        return <div style={{"fontFamily": "sans-serif", "maxWidth": "800px", "margin": "0 auto", "padding": "20px"}}>
            <h1>🤰 MaternAI</h1>
            
            <div style={{"background": "#fff0f5", "padding": "20px", "borderRadius": "10px", "marginBottom": "20px", "border": "1px solid #E91E63"}}>
                <h2 style={{"color": "#E91E63"}}>{patient["name"]}</h2>
                <p><strong>Gestational Week:</strong> {patient["week"]} | <strong>Age:</strong> {patient["age"]}</p>
            </div>

            <div style={{"border": "2px solid #E91E63", "padding": "20px", "borderRadius": "10px", "marginBottom": "20px", "boxShadow": "0 4px 6px rgba(0,0,0,0.1)"}}>
                <h3 style={{"color": "#E91E63"}}>🧠 AI Doctor Analysis</h3>
                <button onClick={runAI} disabled={loading} style={{"background": "#E91E63", "color": "white", "padding": "10px 15px", "border": "none", "borderRadius": "5px", "cursor": "pointer", "fontSize": "16px", "fontWeight": "bold", "transition": "background 0.3s"}}>
                    {loading ? "Analyzing..." : "Run New Analysis"}
                </button>
                {risks.map(lambda r: any -> any {
                    bg_color = r["severity"] == "High" ? "#ffdddd" : (r["severity"] == "Medium" ? "#fffacd" : "#ddffdd");
                    border_color = r["severity"] == "High" ? "#cc0000" : (r["severity"] == "Medium" ? "orange" : "green");
                    return <div key={r["summary"]} style={{"marginTop": "15px", "padding": "15px", "background": bg_color, "borderLeft": "5px solid " + border_color, "borderRadius": "5px", "boxShadow": "0 2px 4px rgba(0,0,0,0.05)"}}>
                        <strong style={{"color": border_color}}>{r["severity"]} Risk:</strong> {r["summary"]}
                    </div>;
                })}
            </div>

            <h3 style={{"color": "#333", "marginBottom": "15px"}}>Quick Metric Entry</h3>
            <div style={{"display": "flex", "gap": "10px", "marginBottom": "20px"}}>
                <button onClick={lambda -> None { addMetric("BP Systolic", 145.0, "mmHg"); }} style={{"padding": "10px", "cursor": "pointer", "background": "#f0f8ff", "border": "1px solid #4682b4", "borderRadius": "5px"}}>🚨 Add High BP (145)</button>
                <button onClick={lambda -> None { addMetric("Glucose", 95.0, "mg/dL"); }} style={{"padding": "10px", "cursor": "pointer", "background": "#f0fff0", "border": "1px solid #3cb371", "borderRadius": "5px"}}>✅ Add Normal Glucose</button>
                <button onClick={lambda -> None { addMetric("BP Systolic", 110.0, "mmHg"); }} style={{"padding": "10px", "cursor": "pointer", "background": "#f0fff0", "border": "1px solid #3cb371", "borderRadius": "5px"}}>✅ Add Normal BP (110)</button>
            </div>

            <h3 style={{"color": "#333", "marginBottom": "10px"}}>Health Metric History</h3>
            <ul style={{"listStyle": "none", "padding": "0"}}>
                {metrics_sorted.map(lambda m: any -> any {
                    bg_color = m["is_abnormal"] ? "#ffdddd" : "white";
                    color = m["is_abnormal"] ? "#cc0000" : "#333";
                    return <li key={m["type"] + m["value"]} style={{"padding": "10px", "borderBottom": "1px solid #eee", "background": bg_color, "color": color, "borderRadius": "3px", "marginBottom": "5px"}}>
                        <strong>{m["type"]}</strong>: <span style={{"fontWeight": "bold"}}>{m["value"]}</span> {m["unit"]} {m["is_abnormal"] ? "(ABNORMAL)" : ""}
                    </li>;
                })}
            </ul>
        </div>;
    }

    def app() -> any {
        return <Dashboard />;
    }
}