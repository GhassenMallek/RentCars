import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MedecinesComponent } from './medecines.component';

describe('MedecinesComponent', () => {
  let component: MedecinesComponent;
  let fixture: ComponentFixture<MedecinesComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ MedecinesComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MedecinesComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
